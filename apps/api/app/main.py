from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import drones, missions, analytics

app = FastAPI(
    title="AetherAg Orbit API",
    description="Backend API for precision agriculture drone swarm management",
    version="0.1.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # Update for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(drones.router, prefix="/api/v1/drones", tags=["drones"])
app.include_router(missions.router, prefix="/api/v1/missions", tags=["missions"])
app.include_router(analytics.router, prefix="/api/v1/analytics", tags=["analytics"])

@app.get("/")
async def root():
    return {
        "message": "AetherAg Orbit API",
        "version": "0.1.0",
        "status": "healthy"
    }

@app.get("/health")
async def health_check():
    return {"status": "healthy"}
