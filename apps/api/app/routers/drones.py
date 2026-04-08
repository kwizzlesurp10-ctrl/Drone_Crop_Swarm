from fastapi import APIRouter, HTTPException
from typing import List
from pydantic import BaseModel

router = APIRouter()

class Drone(BaseModel):
    id: str
    name: str
    status: str
    battery_level: float
    latitude: float
    longitude: float

@router.get("/", response_model=List[Drone])
async def get_drones():
    """Get all drones in the swarm"""
    # TODO: Implement database query
    return []

@router.get("/{drone_id}", response_model=Drone)
async def get_drone(drone_id: str):
    """Get a specific drone by ID"""
    # TODO: Implement database query
    raise HTTPException(status_code=404, detail="Drone not found")

@router.post("/", response_model=Drone)
async def create_drone(drone: Drone):
    """Register a new drone"""
    # TODO: Implement database insert
    return drone
