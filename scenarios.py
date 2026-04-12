from __future__ import annotations

import pandas as pd


def apply_scenario(
    fc: pd.DataFrame,
    *,
    port_weeks: int = 0,
    port_severity: float = 0.25,
    price_change_pct: float = 0.0,
    competitor_promo_lift: float = 0.0,
    price_elasticity: float = -0.45,
) -> pd.DataFrame:
    """
    Adjust point and quantile forecasts for planner what-ifs.
    - Port / logistics shock: scales down demand for the first `port_weeks` horizon steps.
    - Price change: multiplies demand by (1 + elasticity * (pct/100)).
    - Competitor promo: lifts demand proportionally on affected horizon (flat lift for demo).
    """
    out = fc.copy()
    h = out["horizon_week"].values if "horizon_week" in out.columns else None
    mult = pd.Series(1.0, index=out.index, dtype="float64")

    if port_weeks > 0 and h is not None:
        shock = 1.0 - float(port_severity)
        mult = mult * pd.Series(
            [shock if (isinstance(x, (int, float)) and x <= port_weeks) else 1.0 for x in h],
            index=out.index,
        )

    if price_change_pct != 0:
        mult = mult * (1.0 + float(price_elasticity) * (float(price_change_pct) / 100.0))

    if competitor_promo_lift != 0:
        mult = mult * (1.0 + float(competitor_promo_lift))

    for c in (
        "y_hat_p10",
        "y_hat_p50",
        "y_hat_p90",
        "y_hat_ensemble",
        "y_hat_naive",
        "y_hat_lgb",
        "y_hat_classical",
        "y_hat_torch",
    ):
        if c in out.columns:
            out[c] = out[c] * mult

    if "safety_stock_units" in out.columns:
        out["safety_stock_units"] = out["safety_stock_units"] * mult

    return out


def safety_stock_from_quantiles(
    p50: pd.Series | float,
    p90: pd.Series | float,
    z_service: float = 1.28,
) -> pd.Series:
    """Heuristic: base stock from median + buffer from spread (p90-p50) scaled by z."""
    spread = pd.to_numeric(p90, errors="coerce") - pd.to_numeric(p50, errors="coerce")
    spread = spread.clip(lower=0)
    return pd.to_numeric(p50, errors="coerce") + z_service * spread
