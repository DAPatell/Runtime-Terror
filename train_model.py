import pandas as pd
import lightgbm as lgb
from sklearn.model_selection import train_test_split
import joblib


def load_data():
    df = pd.read_parquet("output/final_features.parquet")
    return df


def train():
    df = load_data()

    # Target
    y = df["sales"]

    # Drop unwanted columns
    drop_cols = ["id", "date", "sales"]
    X = df.drop(columns=drop_cols)

    # Convert categorical
    for col in X.select_dtypes("object").columns:
        X[col] = X[col].astype("category")

    # Split data
    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, shuffle=False
    )

    # Model
    model = lgb.LGBMRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=6
    )

    model.fit(X_train, y_train)

    # Save model
    joblib.dump(model, "model/model.pkl")

    print("✅ Model trained and saved!")


if __name__ == "__main__":
    train()