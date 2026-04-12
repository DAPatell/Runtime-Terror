from fastapi import FastAPI, UploadFile, File, Form, Depends, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import duckdb
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import uvicorn
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from src.services import forecast_paths, read_metrics, upload_dir
from src.scenarios import apply_scenario, safety_stock_from_quantiles

app = FastAPI(title="Demand Forecasting API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

frontend_dir = ROOT / "frontend"
frontend_dir.mkdir(parents=True, exist_ok=True)
app.mount("/ui", StaticFiles(directory=str(frontend_dir)), name="ui")

STATE_MAP = { 'CA': 'Maharashtra', 'TX': 'Delhi', 'WI': 'Karnataka' }
STORE_MAP = {
    'CA_1': 'Mumbai', 'CA_2': 'Pune', 'CA_3': 'Nagpur', 'CA_4': 'Nashik',
    'TX_1': 'New Delhi', 'TX_2': 'Gurgaon', 'TX_3': 'Noida',
    'WI_1': 'Bengaluru', 'WI_2': 'Mysuru', 'WI_3': 'Hubli'
}

def map_indian_names(df: pd.DataFrame) -> pd.DataFrame:
    if 'state_id' in df.columns:
        df['state_id'] = df['state_id'].replace(STATE_MAP)
    if 'store_id' in df.columns:
        df['store_id'] = df['store_id'].replace(STORE_MAP)
    if 'id' in df.columns:
        for k, v in STORE_MAP.items():
            df['id'] = df['id'].str.replace(k, v)
    return df

@app.get("/")
def read_root():
    return FileResponse(frontend_dir / "index.html")

@app.get("/api/metrics")
def get_metrics():
    metrics = read_metrics()
    if not metrics:
        return {"error": "No metrics found. Run training first."}
    return metrics

@app.get("/api/forecast/national")
def get_national_forecast():
    paths = forecast_paths()
    p = paths["national"]
    if not p.exists():
        return []
    df = pd.read_parquet(p)
    return df.to_dict(orient="records")

@app.get("/api/forecast/state")
def get_state_forecast():
    paths = forecast_paths()
    p = paths["state"]
    if not p.exists():
        return []
    df = pd.read_parquet(p)
    df = map_indian_names(df)
    return df.to_dict(orient="records")

@app.get("/api/forecast/search")
def search_sku(q: str = ""):
    paths = forecast_paths()
    fc_p = paths["future"]
    if not fc_p.exists():
        return {"error": "No forecasts yet."}
    
    q = q.lower()
    df = pd.read_parquet(fc_p)
    df = map_indian_names(df)
    
    mask = (
        df["state_id"].astype(str).str.lower().str.contains(q, na=False)
        | df["store_id"].astype(str).str.lower().str.contains(q, na=False)
        | df["item_id"].astype(str).str.lower().str.contains(q, na=False)
        | df["id"].astype(str).str.lower().str.contains(q, na=False)
    )
    fc = df.loc[mask]
    ids = sorted(fc["id"].astype(str).unique().tolist())
    return {"ids": ids}

@app.get("/api/forecast/weather-price")
def get_weather_price():
    paths = forecast_paths()
    wk_p = paths["weekly"]
    if not wk_p.exists():
        return {"error": "No weekly panel yet."}
    
    df = pd.read_parquet(wk_p)
    df = df.dropna(subset=['weather_temp_c', 'sell_price', 'sales'])
    
    # 1. Weather aggregation
    w_df = df.copy()
    w_df['temp_bin'] = w_df['weather_temp_c'].round()
    w_agg = w_df.groupby('temp_bin').agg({'sales': 'mean', 'sell_price': 'mean'}).reset_index().sort_values('temp_bin')
    
    # 2. Price aggregation
    p_df = df.copy()
    p_df['price_bin'] = p_df['sell_price'].round(1)
    p_agg = p_df.groupby('price_bin')['sales'].mean().reset_index().sort_values('price_bin')

    return {
        "weather": w_agg.to_dict(orient="records"),
        "price": p_agg.to_dict(orient="records")
    }

class ScenarioRequest(BaseModel):
    sku_id: str
    port_weeks: int = 0
    port_severity: float = 0.25
    price_change_pct: float = 0.0
    promo_lift: float = 0.0

@app.post("/api/scenario")
def run_scenario(req: ScenarioRequest):
    paths = forecast_paths()
    fc_p = paths["future"]
    if not fc_p.exists():
        raise HTTPException(status_code=400, detail="No forecasts available")
        
    df = pd.read_parquet(fc_p)
    df = map_indian_names(df)
    
    sub0 = df.loc[df["id"] == req.sku_id].copy()
    if sub0.empty:
        raise HTTPException(status_code=404, detail="SKU not found")
        
    sub = apply_scenario(
        sub0,
        port_weeks=req.port_weeks,
        port_severity=req.port_severity,
        price_change_pct=req.price_change_pct,
        competitor_promo_lift=req.promo_lift,
    )
    
    if "y_hat_p50" in sub.columns and "y_hat_p90" in sub.columns:
        sub["safety_stock_hint"] = safety_stock_from_quantiles(
            sub["y_hat_p50"], sub["y_hat_p90"], z_service=1.28
        )
        
    hist_p = paths["backtest"]
    hist_data = []
    if hist_p.exists():
        hist = pd.read_parquet(hist_p)
        hist = map_indian_names(hist)
        h = hist.loc[hist["id"] == req.sku_id].sort_values("week_start")
        hist_data = h.to_dict(orient="records")
        
    sub = sub.sort_values("week_start")
    
    # We replace NaN with None for JSON serialization
    sub = sub.where(pd.notnull(sub), None)
    
    return {
        "forecast": sub.to_dict(orient="records"),
        "history": hist_data
    }

if __name__ == "__main__":
    uvicorn.run("api:app", host="0.0.0.0", port=8000, reload=True)
