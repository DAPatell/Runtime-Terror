import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from lightgbm import LGBMRegressor

print("🚀 Starting Prototype...")


dates = pd.date_range(start="2022-01-01", periods=120)

df = pd.DataFrame({
    "date": dates,
    "id": ["item_1"] * 120,
    "sales": np.random.randint(10, 50, 120),
    "sell_price": np.random.uniform(100, 200, 120)
})


df['lag_7'] = df['sales'].shift(7)
df['lag_28'] = df['sales'].shift(28)

df['rmean_7'] = df['sales'].shift(7).rolling(7).mean()

df['day'] = df['date'].dt.day
df['month'] = df['date'].dt.month

df = df.dropna()



features = ['lag_7', 'lag_28', 'rmean_7', 'sell_price', 'day', 'month']
target = 'sales'

X = df[features]
y = df[target]

model = LGBMRegressor()
model.fit(X, y)

df['prediction'] = model.predict(X)


plt.figure()
plt.plot(df['date'], df['sales'], label='Actual')
plt.plot(df['date'], df['prediction'], label='Prediction')
plt.legend()
plt.title("Demand Forecast Prototype")
plt.show()


df_sim = df.copy()
df_sim['sell_price'] *= 1.1  # price increase

df_sim['prediction'] = model.predict(df_sim[features])

print("📊 Scenario Simulation Done (Price Increased)")

