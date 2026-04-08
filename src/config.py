# Model configuration
MODEL_PATH: str = "yolov10x-plant-2026.pt"
MODEL_CONFIDENCE_THRESHOLD: float = 0.25
MODEL_IOU_THRESHOLD: float = 0.45

# Disease type mappings
DISEASE_CLASSES = {
    0: "healthy",
    1: "nutrient_deficiency",
    2: "fungal_infection",
    3: "pest_damage",
    4: "water_stress"
}

# Variable Rate Application (VRA) base rates
VRA_BASE_RATES = {
    "healthy": 0.1,
    "nutrient_deficiency": 0.5,
    "fungal_infection": 0.7,
    "pest_damage": 0.6,
    "water_stress": 0.3,
    "unknown": 0.2,
    "no_detection": 0.0
}

# Logging configuration
LOG_LEVEL: str = "INFO"
LOG_FORMAT: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
