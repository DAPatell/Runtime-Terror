"""CLI: daily features, weekly+train, or full stack. Run from repo root."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


def main() -> None:
    p = argparse.ArgumentParser(description="Supply chain forecasting pipeline")
    p.add_argument("--daily-only", action="store_true", help="Daily parquet features only")
    p.add_argument("--weekly-only", action="store_true", help="Train from existing weekly_panel.parquet")
    p.add_argument("--data-dir", type=Path, default=None, help="Folder with sales_train, calendar, sell_prices")
    p.add_argument("--max-series", type=int, default=None)
    p.add_argument("--last-days", type=int, default=None)
    p.add_argument("--val-weeks", type=int, default=None)
    p.add_argument("--horizon-weeks", type=int, default=None)
    args = p.parse_args()

    from src.config import TrainConfig, default_paths

    cfg = TrainConfig()
    if args.max_series is not None:
        cfg.max_series = int(args.max_series)
    if args.last_days is not None:
        cfg.last_n_days = int(args.last_days)
    if args.val_weeks is not None:
        cfg.validation_weeks = int(args.val_weeks)
    if args.horizon_weeks is not None:
        cfg.forecast_horizon_weeks = int(args.horizon_weeks)

    data_dir = Path(args.data_dir) if args.data_dir else None

    if args.daily_only:
        from src.features import run_pipeline as daily

        daily(data_dir or default_paths().data_dir)
        return

    if args.weekly_only:
        from src.train_forecast import train_and_predict

        paths = default_paths()
        if data_dir is not None:
            paths.data_dir = data_dir
        train_and_predict(paths, cfg)
        return

    from src.pipeline import run_all

    run_all(cfg, data_dir=data_dir)


if __name__ == "__main__":
    main()
