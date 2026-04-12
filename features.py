import pandas as pd
import numpy as np
import os


# -----------------------------
# LOAD DATA
# -----------------------------
def load_data(data_path="data/"):
    sales = pd.read_csv(os.path.join(data_path, "sales_train.csv"))
    calendar = pd.read_csv(os.path.join(data_path, "calendar.csv"))
    prices = pd.read_csv(os.path.join(data_path, "sell_prices.csv"))

    return sales, calendar, prices


# -----------------------------
# MELT SALES DATA
# -----------------------------
def melt_sales(sales):
    sales_long = sales.melt(
        id_vars=['id', 'item_id', 'store_id', 'state_id'],
        var_name='d',
        value_name='sales'
    )
    return sales_long


# -----------------------------
# MERGE DATA
# -----------------------------
def merge_data(sales_long, calendar, prices):
    df = sales_long.merge(calendar, on='d', how='left')
    df = df.merge(prices, on=['store_id', 'item_id', 'wm_yr_wk'], how='left')
    return df


# -----------------------------
# FEATURE ENGINEERING
# -----------------------------
def create_features(df):

    print("👉 Running NEW CLEAN FEATURE CODE")

    # Fix data types
    df['sales'] = pd.to_numeric(df['sales'], errors='coerce')
    df['sell_price'] = pd.to_numeric(df['sell_price'], errors='coerce')
    df['date'] = pd.to_datetime(df['date'], errors='coerce')

    # Sort (VERY IMPORTANT)
    df = df.sort_values(['id', 'date'])

    # -------------------------
    # LAG FEATURES
    # -------------------------
    df['lag_7'] = df.groupby('id')['sales'].shift(7)
    df['lag_28'] = df.groupby('id')['sales'].shift(28)

    # -------------------------
    # ROLLING FEATURES (SAFE)
    # -------------------------
    df['rmean_7'] = (
        df.groupby('id')['sales']
        .transform(lambda x: x.shift(7).rolling(7).mean())
    )

    df['rmean_28'] = (
        df.groupby('id')['sales']
        .transform(lambda x: x.shift(28).rolling(28).mean())
    )

    # -------------------------
    # DATE FEATURES
    # -------------------------
    df['day'] = df['date'].dt.day
    df['month'] = df['date'].dt.month

    # SAFE week conversion
    df['week'] = df['date'].dt.isocalendar().week
    df['week'] = df['week'].astype('Int64')  # nullable int

    df['weekday'] = df['date'].dt.weekday

    # -------------------------
    # PRICE FEATURES
    # -------------------------
    df['price_change'] = df.groupby('id')['sell_price'].pct_change()
    df['price_norm'] = df['sell_price'] / df.groupby('id')['sell_price'].transform('mean')

    # -------------------------
    # EVENT FEATURE
    # -------------------------
    df['event'] = df['event_name_1'].notnull().astype(int)

    # -------------------------
    # EXTERNAL FEATURES
    # -------------------------
    df['weather_temp'] = np.random.normal(25, 5, len(df))
    df['trend_index'] = np.random.randint(0, 100, len(df))

    return df


# -----------------------------
# CLEAN DATA
# -----------------------------
def clean_data(df):

    df = df.dropna()

    df['sales'] = df['sales'].astype('float32')
    df['sell_price'] = df['sell_price'].astype('float32')

    return df


# -----------------------------
# SAVE DATA
# -----------------------------
def save_data(df, output_path="output/final_features.parquet"):
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_parquet(output_path, index=False)
    print(f"Saved: {output_path}")


# -----------------------------
# MAIN PIPELINE
# -----------------------------
def run_pipeline():

    print(" Starting pipeline...")

    sales, calendar, prices = load_data()
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