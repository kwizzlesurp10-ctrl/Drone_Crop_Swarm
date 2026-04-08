import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sentry_sdk
from posthog import Posthog
import torch

# Initialize monitoring
sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    traces_sample_rate=1.0,
    profiles_sample_rate=1.0,
)

posthog = Posthog(
    project_api_key=os.getenv("POSTHOG_KEY"),
    host=os.getenv("POSTHOG_HOST", "https://app.posthog.com")
)

app = FastAPI(title="Drone Crop Swarm GPU Worker")

class ProcessingRequest(BaseModel):
    image_url: str
    farm_id: str
    task_type: str

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "gpu_available": torch.cuda.is_available(),
        "gpu_count": torch.cuda.device_count() if torch.cuda.is_available() else 0
    }

@app.post("/process")
async def process_image(request: ProcessingRequest):
    """Process drone imagery using GPU acceleration"""
    try:
        # Track event
        posthog.capture(
            distinct_id=request.farm_id,
            event="image_processing_started",
            properties={"task_type": request.task_type}
        )

        # TODO: Implement actual image processing logic
        # This is a placeholder for GPU-accelerated processing

        return {
            "status": "processed",
            "farm_id": request.farm_id,
            "task_type": request.task_type
        }
    except Exception as e:
        sentry_sdk.capture_exception(e)
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
