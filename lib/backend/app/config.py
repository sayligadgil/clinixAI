# app/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache
import os

class Settings(BaseSettings):
    # Environment
    APP_ENV: str = os.getenv("APP_ENV", "production")

    # Firebase Configuration
    PROJECT_ID: str = "clinixai-9fd9a"
    FIREBASE_CREDENTIALS_PATH: str = "firebase_config/serviceAccountKey.json"

    # API Configuration
    API_TITLE: str = "ClinixAI Backend"
    API_VERSION: str = "1.0.0"
    API_DESCRIPTION: str = "AI-powered medical consultation platform"

    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours

    ML_MODELS_DIR: str = "app/models" # Update this to match your folder structure

    # Add these two lines to match main.py
    SYMPTOM_CLASSIFIER_PATH: str = f"{ML_MODELS_DIR}/symptom_classifier.pkl"
    LABEL_ENCODER_PATH: str = f"{ML_MODELS_DIR}/label_encoder.pkl"

    # Keep your existing ones if they are used elsewhere
    SYMPTOM_MODEL_PATH: str = SYMPTOM_CLASSIFIER_PATH
    ANOMALY_MODEL_PATH: str = f"{ML_MODELS_DIR}/anomaly_detector.pkl"

    # Hospital IDs
    HOSPITALS: dict = {
        "h001": "Apollo Hospitals, Jubilee Hills",
        "h002": "KIMS-Sunshine Hospitals, Begumpet",
        "h003": "Continental Hospitals, Gachibowli"
    }

    # Risk Thresholds
    ANOMALY_THRESHOLD: float = 0.7
    HIGH_RISK_THRESHOLD: float = 0.8
    AI_CONFIDENCE_THRESHOLD: float = 0.7
    EMBEDDER_MODEL: str = "all-MiniLM-L6-v2"

    # Prescription Rules
    MAX_MEDICATIONS_PER_PRESCRIPTION: int = 5
    REQUIRE_DOCTOR_APPROVAL: bool = True

    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings() -> Settings:
    return Settings()