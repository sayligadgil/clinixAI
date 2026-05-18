"""
main.py  —  CliniX AI FastAPI Application Entry Point
─────────────────────────────────────────────────────────────────────────────
Run locally:
    uvicorn main:app --reload --port 8000

Deploy on Cloud Run:
    gcloud run deploy clinix-backend \
        --source . \
        --platform managed \
        --allow-unauthenticated \
        --region us-central1

Swagger UI:   http://localhost:8000/docs
ReDoc:        http://localhost:8000/redoc
"""
from __future__ import annotations
import logging
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.firebase import init_firebase
from app.ml.symptom_classifier import SymptomClassifier
from app.ml.anomaly_detector import AnomalyDetector
from app.routers import auth, patient, doctor, hospitals, admin

# ─── Logging ──────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)
logger = logging.getLogger("clinix")
# ─── Lifespan: startup / shutdown ────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("🚀 CliniX AI backend starting up...")
    settings = get_settings()

    # Warm up Firebase
    init_firebase()
    logger.info("✅ Firebase initialised")

    # Pre-load ML models so first request isn't slow
    clf = SymptomClassifier(
        model_path=settings.SYMPTOM_MODEL_PATH,
        label_encoder_path=settings.LABEL_ENCODER_PATH,
    )
    logger.info(f"✅ Symptom classifier ready "
                f"({len(clf.label_encoder.classes_)} disease classes)")

    AnomalyDetector()
    logger.info("✅ Anomaly detector ready")

    yield

    logger.info("🛑 CliniX AI backend shutting down.")


# ─── App ──────────────────────────────────────────────────────────────────────
app = FastAPI(
    title="CliniX AI — Backend API",
    lifespan=lifespan,
    description=(
        "AI-powered clinical triage backend.\n\n"
        "**Patient flow**: `/auth/login` → `/patient/intake` → "
        "`/patient/payment/order` → `/patient/payment/verify` → "
        "`/patient/prescription/{id}` → `/patient/prescription/{id}/pdf`\n\n"
        "**Doctor flow**: `/doctor/alerts/{uid}` → "
        "`/doctor/consultation/{id}` → `/doctor/consultation/{id}/review`"
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ─── Middleware ────────────────────────────────────────────────────────────────
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # tighten to your Flutter app domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    duration = (time.perf_counter() - start) * 1000
    logger.info(f"{request.method} {request.url.path} → {response.status_code} ({duration:.1f}ms)")
    return response


# ─── Global error handler ─────────────────────────────────────────────────────
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    import traceback
    logger.exception(f"Unhandled error on {request.url.path}: {exc}")
    return JSONResponse(
        status_code=500,
        content={"success": False, "error": "Internal server error.",
                 "detail": str(exc) + " | Traceback: " + "".join(traceback.format_exception(type(exc), exc, exc.__traceback__))},
    )


# ─── Routers ──────────────────────────────────────────────────────────────────
app.include_router(auth)
app.include_router(patient)
app.include_router(doctor)
app.include_router(hospitals)
app.include_router(admin)


# ─── Health check ────────────────────────────────────────────────────────────
@app.get("/health", tags=["System"])
async def health():
    return {"status": "ok", "service": "CliniX AI Backend", "version": "1.0.0"}


@app.get("/", tags=["System"])
async def root():
    return {
        "message": "CliniX AI API — see /docs for interactive documentation",
        "docs": "/docs",
        "redoc": "/redoc",
    }

if __name__ == "__main__":
    import uvicorn
    # This line tells Uvicorn to host your 'app' on the local port 8000
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
