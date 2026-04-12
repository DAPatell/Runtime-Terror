from __future__ import annotations

from pathlib import Path


def materialize_warehouse(output_dir: Path, db_name: str = "forecast_warehouse.duckdb") -> Path | None:
    try:
        import duckdb
    except ImportError:
        return None

    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    db_path = output_dir / db_name
    con = duckdb.connect(str(db_path))
    try:
        for name, fname in (
            ("forecasts_future", "forecasts_future.parquet"),
            ("forecasts_backtest", "forecasts_backtest.parquet"),
            ("weekly_panel", "weekly_panel.parquet"),
            ("hierarchy_national", "hierarchy_national.parquet"),
            ("hierarchy_state", "hierarchy_state.parquet"),
        ):
            p = output_dir / fname
            if p.exists():
                q = p.resolve().as_posix().replace("'", "''")
                con.execute(f"CREATE OR REPLACE TABLE {name} AS SELECT * FROM read_parquet('{q}')")
        meta = output_dir / "metrics.json"
        if meta.exists():
            payload = meta.read_text(encoding="utf-8")
            con.execute("DROP TABLE IF EXISTS training_metrics")
            con.execute("CREATE TABLE training_metrics (json_text VARCHAR)")
            con.execute("INSERT INTO training_metrics VALUES (?)", [payload])
    finally:
        con.close()
    return db_path
