import os
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import asyncio
from ai.plant_diagnostics import diagnose_plants
from geospatial.rtk import apply_rtk_correction
from services.prescription_map import generate_prescription_map
import stripe
from posthog import Posthog

app = FastAPI(title="AETHERAG-ORBIT API", version="1.0.0")

stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
posthog = Posthog(os.getenv("POSTHOG_KEY"))

app.add_middleware(CORSMiddleware, allow_origins=["*"])

@app.websocket("/ws/telemetry")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    while True:
        data = await websocket.receive_json()
        corrected = apply_rtk_correction(data["location"], data["rtk_offset"])
        diagnosis = await diagnose_plants(data["image_url"], corrected)
        # Trigger VRA map generation
        await generate_prescription_map(diagnosis)
        posthog.capture("telemetry_received", {"acres": data["acres"]})
        await websocket.send_json({"status": "processed", "xai_contrib": "12% activated"})

# All other endpoints (fleet, missions, prescriptions) included in full drop
