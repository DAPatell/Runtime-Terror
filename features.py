import os
from pathlib import Path

import pandas as pd

from src.externals import attach_external_signals


def load_data(data_path: str | Path = "data"):
    root = Path(data_path)
    sales = pd.read_csv(root / "sales_train.csv")
    calendar = pd.read_csv(root / "calendar.csv")
    prices = pd.read_csv(root / "sell_prices.csv")
    return sales, calendar, prices


def melt_sales(sales):
    meta = ["id", "item_id", "dept_id", "cat_id", "store_id", "state_id"]
    meta = [c for c in meta if c in sales.columns]
    return sales.melt(id_vars=meta, var_name="d", value_name="sales")


def merge_data(sales_long, calendar, prices):
    df = sales_long.merge(calendar, on="d", how="left")
    df = df.merge(prices, on=["store_id", "item_id", "wm_yr_wk"], how="left")
    return df


def create_features(df):
    df["sales"] = pd.to_numeric(df["sales"], errors="coerce")
    df["sell_price"] = pd.to_numeric(df["sell_price"], errors="coerce")
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    df = df.sort_values(["id", "date"])

    df["lag_7"] = df.groupby("id")["sales"].shift(7)
    df["lag_28"] = df.groupby("id")["sales"].shift(28)
    df["rmean_7"] = df.groupby("id")["sales"].transform(
        lambda x: x.shift(7).rolling(7).mean()
    )
    df["rmean_28"] = df.groupby("id")["sales"].transform(
        lambda x: x.shift(28).rolling(28).mean()
    )

    df["day"] = df["date"].dt.day
    df["month"] = df["date"].dt.month
    df["week"] = df["date"].dt.isocalendar().week.astype("Int64")
    df["weekday"] = df["date"].dt.weekday

    df["price_change"] = df.groupby("id")["sell_price"].pct_change()
    df["price_norm"] = df["sell_price"] / df.groupby("id")["sell_price"].transform("mean")
    df["event"] = df["event_name_1"].notna().astype(int)

    df["week_start"] = df["date"] - pd.to_timedelta(df["date"].dt.weekday, unit="D")
    df = attach_external_signals(df)
    df["weather_temp"] = df["weather_temp_c"]
    df["trend_index"] = df["social_trend_index"]
    df = df.drop(
        columns=[c for c in ("iso_year", "iso_week") if c in df.columns],
        errors="ignore",
    )

    return df


def clean_data(df):
    df = df.dropna()
    df["sales"] = df["sales"].astype("float32")
    df["sell_price"] = df["sell_price"].astype("float32")
    return df


def save_data(df, output_path="output/final_features.parquet"):
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_parquet(output_path, index=False)
    print(f"Saved: {output_path}")


def run_pipeline(data_path: str | Path = "data"):
    print(" Starting pipeline...")
    sales, calendar, prices = load_data(data_path)
    print("✔ Loaded")
    sales_long = melt_sales(sales)
    print("✔ Melted")
    df = merge_data(sales_long, calendar, prices)
    print("✔ Merged")
    df = create_features(df)
    print("✔ Features created")
    df = clean_data(df)
    print("✔ Cleaned")
    save_data(df)
    print(" DONE SUCCESSFULLY!")


if __name__ == "__main__":
    run_pipeline()
