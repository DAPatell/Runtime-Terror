from __future__ import annotations

import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler

from src.config import Paths, TrainConfig
from src.hierarchy import coherence_score, rollup_hierarchy
from src.scenarios import safety_stock_from_quantiles

try:
    import lightgbm as lgb
except ImportError:
    lgb = None

try:
    import torch
    import torch.nn as nn

    class TinyMLP(nn.Module):
        def __init__(self, n_in: int, hidden: int):
            super().__init__()
            self.net = nn.Sequential(
                nn.Linear(n_in, hidden),
                nn.ReLU(),
                nn.Linear(hidden, max(8, hidden // 2)),
                nn.ReLU(),
                nn.Linear(max(8, hidden // 2), 1),
            )

        def forward(self, x):
            return self.net(x).squeeze(-1)

except ImportError:
    torch = None
    nn = None
    TinyMLP = None  # type: ignore[misc, assignment]


EXT_NUM = [
    "weather_temp_c",
    "weather_precip_index",
    "weather_severe_event",
    "social_trend_index",
    "macro_cci",
    "macro_unemployment_pct",
    "macro_fuel_usd",
    "logistics_stress_0_1",
]


def _add_lags(df: pd.DataFrame) -> pd.DataFrame:
    out = df.copy()
    g = out.groupby("id", sort=False)
    out["lag_1"] = g["sales"].shift(1)
    out["lag_2"] = g["sales"].shift(2)
    out["lag_4"] = g["sales"].shift(4)
    out["lag_8"] = g["sales"].shift(8)
    out["lag_52"] = g["sales"].shift(52)
    out["lag_52"] = out["lag_52"].fillna(out["lag_1"])
    out["roll_mean_4"] = g["sales"].transform(lambda x: x.shift(1).rolling(4, min_periods=1).mean())
    out["roll_std_4"] = g["sales"].transform(lambda x: x.shift(1).rolling(4, min_periods=2).std())
    out["roll_std_4"] = out["roll_std_4"].fillna(0.0)
    out["target"] = g["sales"].shift(-1)
    out["month"] = out["week_start"].dt.month.astype(np.int16)
    return out


def _wmape(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    y_true = np.asarray(y_true, dtype=float)
    y_pred = np.asarray(y_pred, dtype=float)
    num = np.abs(y_true - y_pred).sum()
    den = np.abs(y_true).sum()
    return float(num / den) if den > 1e-12 else 0.0


def _classical_point(df: pd.DataFrame) -> np.ndarray:
    """Damped combination of short memory, smooth level, and seasonal anchor (ETS-style heuristic)."""
    l1 = df["lag_1"].to_numpy(dtype=float)
    rm = df["roll_mean_4"].to_numpy(dtype=float)
    l52 = df["lag_52"].to_numpy(dtype=float)
    rm = np.where(np.isfinite(rm), rm, l1)
    l52 = np.where(np.isfinite(l52), l52, l1)
    out = 0.35 * l1 + 0.35 * rm + 0.30 * l52
    return np.clip(out, 0.0, None)


def _prepare_matrices(
    sub: pd.DataFrame,
    feature_cols: list[str],
    cat_cols: list[str],
) -> tuple[pd.DataFrame, list[str]]:
    X = sub[feature_cols + cat_cols].copy()
    for c in cat_cols:
        X[c] = X[c].astype("category")
    return X, feature_cols + cat_cols


def _train_torch(
    X_tr: np.ndarray,
    y_tr: np.ndarray,
    X_va: np.ndarray,
    y_va: np.ndarray,
    cfg: TrainConfig,
) -> tuple[np.ndarray | None, StandardScaler]:
    if torch is None or nn is None or TinyMLP is None:
        return None, StandardScaler()
    scaler = StandardScaler()
    X_trs = scaler.fit_transform(X_tr)
    X_vas = scaler.transform(X_va)
    device = torch.device("cpu")
    model = TinyMLP(X_trs.shape[1], cfg.torch_hidden).to(device)
    opt = torch.optim.Adam(model.parameters(), lr=0.01)
    loss_fn = nn.SmoothL1Loss()
    tX = torch.tensor(X_trs, dtype=torch.float32, device=device)
    tY = torch.tensor(y_tr, dtype=torch.float32, device=device)
    for _ in range(cfg.torch_epochs):
        model.train()
        opt.zero_grad()
        pred = model(tX)
        loss = loss_fn(pred, tY)
        loss.backward()
        opt.step()
    model.eval()
    with torch.no_grad():
        va_pred = model(torch.tensor(X_vas, dtype=torch.float32, device=device)).cpu().numpy()
    return va_pred, scaler


def train_and_predict(paths: Paths, cfg: TrainConfig) -> None:
    if lgb is None:
        raise RuntimeError("lightgbm is required")

    out_dir = paths.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)
    panel_path = out_dir / "weekly_panel.parquet"
    if not panel_path.exists():
        raise FileNotFoundError("Run the data pipeline first (weekly_panel.parquet missing).")

    raw = pd.read_parquet(panel_path)
    df = _add_lags(raw)
    df = df.dropna(subset=["lag_1", "target"]).reset_index(drop=True)

    last_week = df["week_start"].max()
    cut = last_week - pd.Timedelta(weeks=cfg.validation_weeks)
    train_mask = df["week_start"] <= cut
    val_mask = df["week_start"] > cut

    num_cols = [
        "lag_1",
        "lag_2",
        "lag_4",
        "lag_8",
        "lag_52",
        "roll_mean_4",
        "roll_std_4",
        "sell_price",
        "snap",
        "has_event",
        "month",
    ] + [c for c in EXT_NUM if c in df.columns]

    cat_cols = [c for c in ("state_id", "store_id", "dept_id", "cat_id") if c in df.columns]
    feature_cols = [c for c in num_cols if c in df.columns]

    tr = df.loc[train_mask]
    va = df.loc[val_mask]

    X_tr, all_cols = _prepare_matrices(tr, feature_cols, cat_cols)
    X_va, _ = _prepare_matrices(va, feature_cols, cat_cols)
    y_tr = tr["target"].to_numpy(dtype=np.float32)
    y_va = va["target"].to_numpy(dtype=np.float32)

    common_lgb = dict(
        n_estimators=cfg.lgb_n_estimators,
        learning_rate=cfg.lgb_learning_rate,
        max_depth=-1,
        num_leaves=63,
        subsample=0.85,
        colsample_bytree=0.85,
        random_state=cfg.random_seed,
        verbosity=-1,
    )

    models = {}
    for alpha, name in [(0.1, "p10"), (0.5, "p50"), (0.9, "p90")]:
        m = lgb.LGBMRegressor(objective="quantile", alpha=alpha, **common_lgb)
        m.fit(X_tr, y_tr)
        models[name] = m

    pred_va = {k: models[k].predict(X_va) for k in models}

    naive_va = np.where(
        np.isfinite(va["lag_52"].to_numpy(dtype=float)),
        va["lag_52"].to_numpy(dtype=float),
        va["lag_1"].to_numpy(dtype=float),
    ).astype(float)
    classical_va = _classical_point(va)

    w_lgb = _wmape(y_va, pred_va["p50"])
    w_nv = _wmape(y_va, naive_va)
    w_cl = _wmape(y_va, classical_va)
    eps = 1e-6
    wl = 1.0 / (w_lgb + eps)
    wn = 1.0 / (w_nv + eps)
    wc = 1.0 / (w_cl + eps)

    torch_va = None
    scaler = StandardScaler()
    wt = 0.0
    if torch is not None and TinyMLP is not None:
        X_tr_np = tr[feature_cols].to_numpy(dtype=np.float32)
        X_va_np = va[feature_cols].to_numpy(dtype=np.float32)
        X_tr_np = np.nan_to_num(X_tr_np, nan=0.0, posinf=0.0, neginf=0.0)
        X_va_np = np.nan_to_num(X_va_np, nan=0.0, posinf=0.0, neginf=0.0)
        torch_va, scaler = _train_torch(X_tr_np, y_tr, X_va_np, y_va, cfg)
        if torch_va is not None:
            wt = 1.0 / (_wmape(y_va, torch_va) + eps)

    w_sum = wl + wn + wc + wt
    ens_va = (
        wl * pred_va["p50"] + wn * naive_va + wc * classical_va + (wt * torch_va if torch_va is not None else 0.0)
    ) / w_sum

    calib = float(np.mean((pred_va["p10"] <= y_va) & (y_va <= pred_va["p90"])))

    metrics = {
        "wmape_lgb_p50": w_lgb,
        "wmape_naive_seasonal": w_nv,
        "wmape_classical_ets_style": w_cl,
        "wmape_ensemble": _wmape(y_va, ens_va),
        "ensemble_weight_lgb": float(wl / w_sum),
        "ensemble_weight_naive": float(wn / w_sum),
        "ensemble_weight_classical": float(wc / w_sum),
        "ensemble_weight_torch": float(wt / w_sum) if wt > 0 else 0.0,
        "calibration_p10_p90_coverage": calib,
    }
    if torch_va is not None:
        metrics["wmape_torch_mlp"] = _wmape(y_va, torch_va)

    backtest = va[
        [
            "id",
            "item_id",
            "store_id",
            "state_id",
            "week_start",
            "sales",
            "target",
        ]
    ].copy()
    backtest["y_actual"] = backtest["target"]
    backtest["y_hat_lgb"] = pred_va["p50"]
    backtest["y_hat_p10"] = pred_va["p10"]
    backtest["y_hat_p50"] = pred_va["p50"]
    backtest["y_hat_p90"] = pred_va["p90"]
    backtest["y_hat_naive"] = naive_va
    backtest["y_hat_classical"] = classical_va
    backtest["y_hat_ensemble"] = ens_va
    if torch_va is not None:
        backtest["y_hat_torch"] = torch_va

    backtest["safety_stock_units"] = safety_stock_from_quantiles(
        backtest["y_hat_p50"], backtest["y_hat_p90"], z_service=1.28
    )

    cat_levels = {c: sorted(tr[c].astype(str).unique().tolist()) for c in cat_cols}

    bt_coh = backtest.copy()
    bt_coh["fc_point"] = bt_coh["y_hat_ensemble"]
    metrics["hierarchical_coherence_mape_gap"] = coherence_score(bt_coh, "fc_point")

    bundle = {
        "models": models,
        "feature_cols": feature_cols,
        "cat_cols": cat_cols,
        "cat_levels": cat_levels,
        "ensemble_weights": {
            "lgb": float(wl / w_sum),
            "naive": float(wn / w_sum),
            "classical": float(wc / w_sum),
            "torch": float(wt / w_sum) if wt > 0 else 0.0,
        },
        "scaler": scaler,
    }
    joblib.dump(bundle, out_dir / "model_bundle.joblib")
    joblib.dump(bundle, out_dir / "lgb_bundle.joblib")

    if torch is not None and torch_va is not None and TinyMLP is not None:
        # retrain torch on full numeric features for deployment
        full = df.loc[train_mask | val_mask]
        X_full_np = np.nan_to_num(
            full[feature_cols].to_numpy(dtype=np.float32),
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )
        y_full = full["target"].to_numpy(dtype=np.float32)
        scaler_f = StandardScaler()
        Xs = scaler_f.fit_transform(X_full_np)
        device = torch.device("cpu")
        mlp = TinyMLP(Xs.shape[1], cfg.torch_hidden).to(device)
        opt = torch.optim.Adam(mlp.parameters(), lr=0.01)
        loss_fn = nn.SmoothL1Loss()
        tX = torch.tensor(Xs, dtype=torch.float32, device=device)
        tY = torch.tensor(y_full, dtype=torch.float32, device=device)
        for _ in range(cfg.torch_epochs):
            mlp.train()
            opt.zero_grad()
            pred = mlp(tX)
            loss = loss_fn(pred, tY)
            loss.backward()
            opt.step()
        torch.save(
            {"state_dict": mlp.state_dict(), "n_in": Xs.shape[1], "hidden": cfg.torch_hidden},
            out_dir / "torch_mlp.pt",
        )

    backtest.to_parquet(out_dir / "forecasts_backtest.parquet", index=False)

    bt_h = backtest.copy()
    bt_h["fc_point"] = bt_h["y_hat_ensemble"]
    hier = rollup_hierarchy(bt_h, "fc_point")
    hier["national"].to_parquet(out_dir / "hierarchy_national.parquet", index=False)
    hier["state"].to_parquet(out_dir / "hierarchy_state.parquet", index=False)

    (out_dir / "metrics.json").write_text(json.dumps(metrics, indent=2), encoding="utf-8")

    wf_sum = wl + wn + wc
    fl = float(wl / wf_sum)
    fn = float(wn / wf_sum)
    fcw = float(wc / wf_sum)
    _future_horizon(
        df, models, feature_cols, cat_cols, cat_levels, cfg, paths, fl, fn, fcw
    )

    from src.duckdb_export import materialize_warehouse

    dbp = materialize_warehouse(out_dir)
    if dbp is not None:
        metrics["duckdb_warehouse"] = str(dbp.resolve())
    (out_dir / "metrics.json").write_text(json.dumps(metrics, indent=2), encoding="utf-8")


def _one_step_features(
    row_template: pd.Series,
    history: list[float],
    next_week: pd.Timestamp,
) -> pd.Series:
    r = row_template.copy()
    r["week_start"] = next_week
    h = history[-1::-1]

    def take(k, default=0.0):
        return float(h[k]) if len(h) > k else default

    r["lag_1"] = take(0)
    r["lag_2"] = take(1)
    r["lag_4"] = take(3)
    r["lag_8"] = take(7)
    r["lag_52"] = take(51, take(0))
    tail = history[-4:] if len(history) >= 4 else history
    r["roll_mean_4"] = float(np.mean(tail)) if tail else 0.0
    r["roll_std_4"] = float(np.std(tail)) if len(tail) > 1 else 0.0
    r["month"] = int(next_week.month)
    return r


def _future_horizon(
    df: pd.DataFrame,
    models: dict,
    feature_cols: list[str],
    cat_cols: list[str],
    cat_levels: dict[str, list[str]],
    cfg: TrainConfig,
    paths: Paths,
    w_lgb: float,
    w_naive: float,
    w_classical: float,
) -> None:
    out_rows = []
    last_week = df["week_start"].max()
    gdf = df.sort_values(["id", "week_start"]).groupby("id", sort=False)

    for sid, part in gdf:
        part = part.reset_index(drop=True)
        if len(part) < 8:
            continue
        last = part.iloc[-1]
        hist = part["sales"].tolist()
        template = last.copy()
        week = pd.Timestamp(last["week_start"]) + pd.Timedelta(days=7)

        for h in range(1, cfg.forecast_horizon_weeks + 1):
            row = _one_step_features(template, hist, week)
            for c in cat_cols:
                row[c] = last[c]
            Xrow = pd.DataFrame([row])
            Xrow = Xrow.reindex(columns=feature_cols + cat_cols)
            for c in feature_cols:
                if c in Xrow.columns:
                    Xrow[c] = pd.to_numeric(Xrow[c], errors="coerce").fillna(0.0)
            for c in cat_cols:
                Xrow[c] = pd.Categorical(
                    Xrow[c].astype(str),
                    categories=cat_levels.get(c, sorted(Xrow[c].astype(str).unique())),
                )

            p10 = float(models["p10"].predict(Xrow)[0])
            p50 = float(models["p50"].predict(Xrow)[0])
            p90 = float(models["p90"].predict(Xrow)[0])
            lag52 = float(row["lag_52"])
            lag1 = float(row["lag_1"])
            naive = float(lag52 if np.isfinite(lag52) and lag52 > 0 else lag1)
            tail = hist[-4:] if len(hist) >= 4 else hist
            rm = float(np.mean(tail)) if tail else lag1
            l52h = float(hist[-52]) if len(hist) >= 52 else lag1
            classical = max(0.0, 0.35 * lag1 + 0.35 * rm + 0.30 * l52h)
            ens = max(
                0.0,
                w_lgb * p50 + w_naive * naive + w_classical * classical,
            )

            out_rows.append(
                {
                    "id": sid,
                    "item_id": last["item_id"],
                    "store_id": last["store_id"],
                    "state_id": last["state_id"],
                    "week_start": week,
                    "horizon_week": h,
                    "y_hat_p10": max(0.0, p10),
                    "y_hat_p50": max(0.0, p50),
                    "y_hat_p90": max(0.0, p90),
                    "y_hat_lgb": max(0.0, p50),
                    "y_hat_naive": max(0.0, naive),
                    "y_hat_ensemble": max(0.0, ens),
                    "safety_stock_units": float(
                        safety_stock_from_quantiles(
                            pd.Series([max(0.0, p50)]),
                            pd.Series([max(0.0, p90)]),
                            z_service=1.28,
                        ).iloc[0]
                    ),
                }
            )
            hist.append(max(0.0, ens))
            week = week + pd.Timedelta(days=7)

    fut = pd.DataFrame(out_rows)
    fut.to_parquet(paths.output_dir / "forecasts_future.parquet", index=False)
