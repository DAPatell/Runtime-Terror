from __future__ import annotations

import sys
from pathlib import Path

import pandas as pd
import plotly.graph_objects as go
import streamlit as st

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from src.config import TrainConfig
from src.scenarios import apply_scenario, safety_stock_from_quantiles
from src.services import (
    default_data_dir,
    duckdb_rowcount,
    forecast_paths,
    read_metrics,
    repo_root,
    run_training,
    save_uploads,
    upload_dir,
)

st.set_page_config(
    page_title="SC Forecast Console",
    layout="wide",
    initial_sidebar_state="expanded",
)

st.markdown(
    """
<style>
    div[data-testid="stMetricValue"] { font-size: 1.45rem; }
    .block-container { padding-top: 1.2rem; }
</style>
""",
    unsafe_allow_html=True,
)


@st.cache_data(ttl=30)
def _load_parquet(path_str: str) -> pd.DataFrame:
    p = Path(path_str)
    if not p.exists():
        return pd.DataFrame()
    return pd.read_parquet(p)


def _fan_chart(sub: pd.DataFrame, title: str) -> go.Figure:
    sub = sub.sort_values("week_start")
    x = sub["week_start"]
    fig = go.Figure()
    fig.add_trace(
        go.Scatter(
            x=x,
            y=sub["y_hat_p10"],
            name="p10",
            line=dict(width=0),
            mode="lines",
            showlegend=False,
        )
    )
    fig.add_trace(
        go.Scatter(
            x=x,
            y=sub["y_hat_p90"],
            name="interval",
            fill="tonexty",
            fillcolor="rgba(76, 201, 240, 0.22)",
            line=dict(width=0),
            mode="lines",
        )
    )
    fig.add_trace(
        go.Scatter(
            x=x,
            y=sub["y_hat_p50"],
            name="p50",
            line=dict(color="#4cc9f0", width=2.5),
            mode="lines+markers",
        )
    )
    fig.add_trace(
        go.Scatter(
            x=x,
            y=sub["y_hat_ensemble"],
            name="ensemble",
            line=dict(color="#f4a261", width=2, dash="dot"),
            mode="lines",
        )
    )
    fig.update_layout(
        title=title,
        height=440,
        legend=dict(orientation="h", yanchor="bottom", y=1.02, x=0),
        margin=dict(l=48, r=24, t=56, b=48),
        paper_bgcolor="rgba(0,0,0,0)",
        plot_bgcolor="rgba(0,0,0,0)",
        yaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
        xaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
    )
    return fig


with st.sidebar:
    st.header("Console")
    st.caption(str(repo_root()))
    use_uploads = st.toggle("Prefer `data/uploads` when present", value=True)
    data_root = default_data_dir()
    if use_uploads and list(upload_dir().glob("*.csv")):
        data_root = upload_dir()
    if "data_root" in st.session_state:
        data_root = Path(st.session_state["data_root"])
    st.caption(f"Data: `{data_root}`")

    st.subheader("Replace inputs")
    up_sales = st.file_uploader("sales_train.csv", type=["csv"])
    up_cal = st.file_uploader("calendar.csv", type=["csv"])
    up_price = st.file_uploader("sell_prices.csv", type=["csv"])
    if st.button("Save uploads", use_container_width=True):
        data_root = save_uploads(up_sales, up_cal, up_price)
        st.session_state["data_root"] = str(data_root)
        st.success(f"Using `{data_root}`")
        st.cache_data.clear()

    if "data_root" in st.session_state:
        data_root = Path(st.session_state["data_root"])

    st.divider()
    st.subheader("Training")
    max_series = st.number_input("Max series", 200, 20000, 2800, 100)
    last_days = st.number_input("Last N days", 120, 1913, 800, 1)
    val_weeks = st.number_input("Validation weeks", 2, 24, 8, 1)
    horizon = st.number_input("Forecast horizon (weeks)", 1, 12, 4, 1)
    n_est = st.number_input("LGBM trees", 50, 1200, 400, 50)
    lr = st.slider("LGBM learning rate", 0.01, 0.3, 0.05, 0.01)

    if st.button("Run full pipeline", type="primary", use_container_width=True):
        cfg = TrainConfig(
            max_series=int(max_series),
            last_n_days=int(last_days),
            validation_weeks=int(val_weeks),
            forecast_horizon_weeks=int(horizon),
            lgb_n_estimators=int(n_est),
            lgb_learning_rate=float(lr),
        )
        try:
            with st.spinner("Building weekly panel, training models, exporting…"):
                run_training(cfg, data_dir=data_root)
            st.cache_data.clear()
            st.success("Pipeline finished.")
        except Exception as e:
            st.error(str(e))

    st.divider()
    fp = forecast_paths()
    if fp["future"].exists():
        try:
            n = duckdb_rowcount(fp["future"])
            st.caption(f"DuckDB rowcount (future): **{n:,}**")
        except Exception:
            pass


paths = forecast_paths()
metrics = read_metrics()

tab_dash, tab_plan, tab_hier, tab_sig, tab_raw = st.tabs(
    ["Dashboard", "Planner", "Hierarchy", "Signals", "Artifacts"]
)

with tab_dash:
    st.title("Supply chain forecast console")
    c1, c2, c3, c4 = st.columns(4)
    if metrics:
        c1.metric("WMAPE (ensemble)", f"{metrics.get('wmape_ensemble', 0):.4f}")
        c2.metric("WMAPE (LGBM p50)", f"{metrics.get('wmape_lgb_p50', 0):.4f}")
        c3.metric("Interval coverage", f"{metrics.get('calibration_p10_p90_coverage', 0):.2%}")
        c4.metric("Coherence gap", f"{metrics.get('hierarchical_coherence_mape_gap', 0):.6f}")
        c5, c6, c7, c8 = st.columns(4)
        c5.metric("WMAPE (classical)", f"{metrics.get('wmape_classical_ets_style', 0):.4f}")
        c6.metric("WMAPE (naive)", f"{metrics.get('wmape_naive_seasonal', 0):.4f}")
        th = metrics.get("wmape_torch_mlp")
        c7.metric("WMAPE (torch)", f"{th:.4f}" if th is not None else "n/a")
        c8.metric("DuckDB", "ok" if metrics.get("duckdb_warehouse") else "—")
        w1, w2, w3, w4 = st.columns(4)
        w1.caption(f"LGBM weight **{metrics.get('ensemble_weight_lgb', 0):.3f}**")
        w2.caption(f"Naive weight **{metrics.get('ensemble_weight_naive', 0):.3f}**")
        w3.caption(f"Classical weight **{metrics.get('ensemble_weight_classical', 0):.3f}**")
        w4.caption(f"Torch weight **{metrics.get('ensemble_weight_torch', 0):.3f}**")
    else:
        c1.info("No metrics yet — run training from the sidebar.")

    nat_p = paths["national"]
    nat = _load_parquet(str(nat_p))
    if len(nat):
        fig = go.Figure(
            go.Scatter(
                x=nat["week_start"],
                y=nat["fc_point"],
                mode="lines",
                line=dict(color="#a78bfa", width=2),
            )
        )
        fig.update_layout(
            title="National demand (bottom-up, validation window)",
            height=360,
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            yaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
        )
        st.plotly_chart(fig, use_container_width=True)
    else:
        st.info("Train models to populate hierarchy charts.")

    if metrics:
        with st.expander("Raw metrics JSON"):
            st.json(metrics)

with tab_plan:
    st.subheader("Area & SKU")
    q = st.text_input("Search state, store, or SKU", "").strip().lower()

    fc_p = paths["future"]
    if not fc_p.exists():
        st.warning("No forecasts yet. Run **Run full pipeline** in the sidebar.")
    else:
        fc = _load_parquet(str(fc_p))
        if q:
            mask = (
                fc["state_id"].astype(str).str.lower().str.contains(q, na=False)
                | fc["store_id"].astype(str).str.lower().str.contains(q, na=False)
                | fc["item_id"].astype(str).str.lower().str.contains(q, na=False)
            )
            fc = fc.loc[mask]
        ids = sorted(fc["id"].astype(str).unique().tolist())
        if not ids:
            st.error("No matches.")
        else:
            pick = st.selectbox("SKU × location", ids, format_func=lambda x: str(x)[:96])
            sub0 = fc.loc[fc["id"] == pick].copy()

            st.markdown("##### Scenario levers")
            a1, a2, a3 = st.columns(3)
            port_w = int(a1.number_input("Port disruption (weeks)", 0, 12, 0))
            port_s = float(a1.slider("Disruption depth", 0.0, 0.7, 0.22))
            price_pct = float(a2.number_input("Price change %", -40.0, 40.0, 0.0, step=0.5))
            promo = float(a3.slider("Competitor promo lift", 0.0, 0.4, 0.0))

            sub = apply_scenario(
                sub0,
                port_weeks=port_w,
                port_severity=port_s,
                price_change_pct=price_pct,
                competitor_promo_lift=promo,
            )

            st.plotly_chart(
                _fan_chart(sub, "Forward weeks — probabilistic fan (with scenario)"),
                use_container_width=True,
            )

            bt_p = paths["backtest"]
            hist = _load_parquet(str(bt_p))
            if len(hist):
                h = hist.loc[hist["id"] == pick].sort_values("week_start")
                if len(h):
                    fig2 = go.Figure()
                    fig2.add_trace(
                        go.Bar(x=h["week_start"], y=h["y_actual"], name="actual", marker_color="#4361ee")
                    )
                    fig2.add_trace(
                        go.Scatter(
                            x=h["week_start"],
                            y=h["y_hat_ensemble"],
                            name="ensemble",
                            line=dict(color="#f4a261", width=2),
                        )
                    )
                    if "y_hat_classical" in h.columns:
                        fig2.add_trace(
                            go.Scatter(
                                x=h["week_start"],
                                y=h["y_hat_classical"],
                                name="classical",
                                line=dict(color="#2ec4b6", width=1.5, dash="dash"),
                            )
                        )
                    if "y_hat_torch" in h.columns:
                        fig2.add_trace(
                            go.Scatter(
                                x=h["week_start"],
                                y=h["y_hat_torch"],
                                name="torch",
                                line=dict(color="#e056fd", width=1.5, dash="dot"),
                            )
                        )
                    fig2.update_layout(
                        title="Holdout window — actual vs ensemble",
                        height=380,
                        barmode="overlay",
                        bargap=0.25,
                        paper_bgcolor="rgba(0,0,0,0)",
                        plot_bgcolor="rgba(0,0,0,0)",
                        yaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
                        xaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
                    )
                    st.plotly_chart(fig2, use_container_width=True)

            sub_disp = sub.copy()
            if "y_hat_p50" in sub_disp.columns and "y_hat_p90" in sub_disp.columns:
                sub_disp["safety_stock_hint"] = safety_stock_from_quantiles(
                    sub_disp["y_hat_p50"], sub_disp["y_hat_p90"], z_service=1.28
                )
            st.dataframe(sub_disp, use_container_width=True, hide_index=True)

with tab_hier:
    st_p = paths["state"]
    st_df = _load_parquet(str(st_p))
    if len(st_df):
        states = sorted(st_df["state_id"].astype(str).unique().tolist())
        sel = st.multiselect("States", states, default=states[: min(3, len(states))])
        view = st_df[st_df["state_id"].isin(sel)]
        fig = go.Figure()
        for s in sel:
            chunk = view.loc[view["state_id"] == s]
            fig.add_trace(
                go.Scatter(
                    x=chunk["week_start"],
                    y=chunk["fc_point"],
                    mode="lines",
                    name=str(s),
                )
            )
        fig.update_layout(
            title="State roll-ups (validation coherence path)",
            height=420,
            paper_bgcolor="rgba(0,0,0,0)",
            plot_bgcolor="rgba(0,0,0,0)",
            yaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
            xaxis=dict(gridcolor="rgba(255,255,255,0.08)"),
        )
        st.plotly_chart(fig, use_container_width=True)
        st.dataframe(view, use_container_width=True, hide_index=True)
    else:
        st.info("Train once to emit `hierarchy_state.parquet`.")

with tab_sig:
    wk_p = paths["weekly"]
    wk = _load_parquet(str(wk_p))
    if len(wk) == 0:
        st.info("Weekly panel appears after training.")
    else:
        cols = [
            c
            for c in wk.columns
            if c
            in (
                "week_start",
                "state_id",
                "weather_temp_c",
                "weather_precip_index",
                "social_trend_index",
                "macro_cci",
                "macro_unemployment_pct",
                "macro_fuel_usd",
                "logistics_stress_0_1",
            )
            or c.startswith("macro_")
            or c.startswith("weather_")
            or c.startswith("social_")
        ]
        cols = [c for c in cols if c in wk.columns]
        sample = wk[cols].drop_duplicates().head(500)
        st.dataframe(sample, use_container_width=True, hide_index=True)
        if "week_start" in wk.columns and "sales" in wk.columns:
            agg = (
                wk.assign(m=pd.to_datetime(wk["week_start"]).dt.month)
                .groupby("m", as_index=False)["sales"]
                .mean()
            )
            fig = go.Figure(
                go.Scatter(x=agg["m"], y=agg["sales"], mode="lines+markers", line=dict(color="#2ec4b6"))
            )
            fig.update_layout(
                title="Average weekly demand by calendar month (sampled series)",
                height=320,
                paper_bgcolor="rgba(0,0,0,0)",
                plot_bgcolor="rgba(0,0,0,0)",
            )
            st.plotly_chart(fig, use_container_width=True)

with tab_raw:
    st.subheader("Output files")
    out = ROOT / "output"
    if out.exists():
        for f in sorted(out.glob("*")):
            st.write(f"`{f.name}` — {f.stat().st_size // 1024} KB")
    else:
        st.caption("No output directory yet.")
    ddb = paths.get("duckdb")
    if ddb is not None and Path(ddb).exists():
        st.success(f"DuckDB warehouse: `{ddb}`")
    st.subheader("Daily feature pipeline")
    st.code("python run_features.py", language="bash")
    st.subheader("Weekly + train (CLI)")
    st.code("python run_forecast.py", language="bash")
    st.subheader("Full CLI (daily / weekly / all)")
    st.code(
        "python run_pipeline.py --daily-only\npython run_pipeline.py --weekly-only\npython run_pipeline.py --max-series 2000",
        language="bash",
    )
    st.subheader("This UI")
    st.code("streamlit run app.py", language="bash")
