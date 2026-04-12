from __future__ import annotations

import json
import shutil
from pathlib import Path
from typing import Any

import duckdb

from src.config import Paths, TrainConfig, default_paths


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def output_dir() -> Path:
    p = default_paths().output_dir
    p.mkdir(parents=True, exist_ok=True)
    return p


def default_data_dir() -> Path:
    return default_paths().data_dir


def upload_dir() -> Path:
    d = repo_root() / "data" / "uploads"
    d.mkdir(parents=True, exist_ok=True)
    return d


def save_uploads(
    sales_file: Any | None,
    calendar_file: Any | None,
    prices_file: Any | None,
) -> Path:
    """
    Persist Streamlit uploads to data/uploads/. Partial updates merge with existing files.
    Returns directory that should be used as data root (uploads if any file saved).
    """
    dest = upload_dir()
    base = default_data_dir()
    touched = False
    if sales_file is not None:
        dest.joinpath("sales_train.csv").write_bytes(sales_file.getvalue())
        touched = True
    if calendar_file is not None:
        dest.joinpath("calendar.csv").write_bytes(calendar_file.getvalue())
        touched = True
    if prices_file is not None:
        dest.joinpath("sell_prices.csv").write_bytes(prices_file.getvalue())
        touched = True
    if not touched:
        return base
    for name in ("sales_train.csv", "calendar.csv", "sell_prices.csv"):
        src = base / name
        dp = dest / name
        if not dp.exists() and src.exists():
            shutil.copy2(src, dp)
    return dest


def resolve_paths(data_dir: Path | None = None) -> Paths:
    paths = default_paths()
    if data_dir is not None:
        paths.data_dir = Path(data_dir)
    return paths


def run_training(cfg: TrainConfig, data_dir: Path | None = None) -> None:
    from src.pipeline import run_all

    run_all(cfg, data_dir=data_dir)


def read_metrics(path: Path | None = None) -> dict | None:
    path = path or (output_dir() / "metrics.json")
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def forecast_paths() -> dict[str, Path]:
    out = output_dir()
    return {
        "future": out / "forecasts_future.parquet",
        "backtest": out / "forecasts_backtest.parquet",
        "weekly": out / "weekly_panel.parquet",
        "national": out / "hierarchy_national.parquet",
        "state": out / "hierarchy_state.parquet",
        "duckdb": out / "forecast_warehouse.duckdb",
    }


def duckdb_rowcount(parquet_path: Path) -> int:
    p = parquet_path.resolve().as_posix()
    con = duckdb.connect(database=":memory:")
    try:
        return int(con.execute(f"SELECT COUNT(*) FROM read_parquet('{p}')").fetchone()[0])
    finally:
        con.close()
