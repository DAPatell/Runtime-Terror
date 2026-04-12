import pandas as pd
p = "output/weekly_panel.parquet"
df = pd.read_parquet(p)
print(df.columns.tolist())
print(df.head())
