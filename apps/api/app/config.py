from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    # API Settings
    api_host: str = "0.0.0.0"
    api_port: int = 8000

    # Database
    database_url: str

    # Supabase
    supabase_url: str
    supabase_key: str

    # Authentication
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # AI Models
    yolo_model_path: str = "./models/yolov10n.pt"
    sam2_checkpoint: str = "./models/sam2_checkpoint.pt"

    class Config:
        env_file = ".env"
        case_sensitive = False

@lru_cache()
def get_settings():
    return Settings()
