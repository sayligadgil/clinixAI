from fastapi import APIRouter, HTTPException, status, Depends, Security
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth as firebase_auth, firestore
from pydantic import BaseModel
from typing import Dict, Optional
from ..config import get_settings

from ..models.schemas import (
    DoctorRegistration, PatientRegistration,
    LoginRequest, AuthResponse, UserRole, SuccessResponse
)
from ..firebase import firebase_helper, get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])
security = HTTPBearer(auto_error=True)
security_optional = HTTPBearer(auto_error=False)

# ============= DEPENDENCIES (Required by other routers) =============

class CurrentUser(BaseModel):
    uid: str
    email: str
    role: str
    hospital_id: Optional[str] = None

async def get_current_user(res: HTTPAuthorizationCredentials = Depends(security)) -> CurrentUser:
    """Verifies the Firebase ID Token and returns user data"""
    try:
        # Directly use Firebase Admin SDK with clock skew allowance
        decoded_token = firebase_auth.verify_id_token(res.credentials, clock_skew_seconds=60)

        uid = decoded_token.get("uid")
        email = decoded_token.get("email")

        # Get custom claims for role
        try:
            user = firebase_auth.get_user(uid)
            custom_claims = user.custom_claims or {}
        except Exception:
            custom_claims = {}

        return CurrentUser(
            uid=uid,
            email=email or "",
            role=custom_claims.get("role", "patient"),
            hospital_id=custom_claims.get("hospital_id")
        )

    except (firebase_auth.InvalidIdTokenError, firebase_auth.ExpiredIdTokenError) as e:
        settings = get_settings()
        if res.credentials == settings.TEST_AUTH_TOKEN:
            return CurrentUser(uid="test-patient", email="test@example.com", role="patient", hospital_id=None)
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")
    except Exception as e:
        # Fallback: if token matches test auth token, create dummy user
        settings = get_settings()
        if res.credentials == settings.TEST_AUTH_TOKEN:
            # Create a dummy patient user for testing purposes
            return CurrentUser(uid="test-patient", email="test@example.com", role="patient", hospital_id=None)
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")

def require_doctor(user: CurrentUser = Depends(get_current_user)):
    if user.role != "doctor":
        raise HTTPException(status_code=403, detail="Doctor access required")
    return user

def require_patient(user: CurrentUser = Depends(get_current_user)):
    if user.role not in ("patient", "guest"):
        raise HTTPException(status_code=403, detail="Patient access required")
    return user

async def get_current_user_any(res: HTTPAuthorizationCredentials = Depends(security)) -> CurrentUser:
    """Verifies the Firebase ID Token and returns user data WITHOUT role enforcement.
    Used for endpoints accessible by both registered and seamless-login patients."""
    try:
        decoded_token = firebase_auth.verify_id_token(res.credentials, clock_skew_seconds=60)
        uid = decoded_token.get("uid")
        email = decoded_token.get("email", "")
        try:
            user = firebase_auth.get_user(uid)
            custom_claims = user.custom_claims or {}
        except Exception:
            custom_claims = {}
        return CurrentUser(
            uid=uid,
            email=email or "",
            role=custom_claims.get("role", "patient"),
            hospital_id=custom_claims.get("hospital_id")
        )
    except (firebase_auth.InvalidIdTokenError, firebase_auth.ExpiredIdTokenError) as e:
        settings = get_settings()
        if res.credentials == settings.TEST_AUTH_TOKEN:
            return CurrentUser(uid="test-patient", email="test@example.com", role="patient", hospital_id=None)
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")
    except Exception as e:
        settings = get_settings()
        if res.credentials == settings.TEST_AUTH_TOKEN:
            return CurrentUser(uid="test-patient", email="test@example.com", role="patient", hospital_id=None)
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")

async def get_optional_user(res: HTTPAuthorizationCredentials = Depends(security_optional)) -> Optional[CurrentUser]:
    if not res:
        return None
    try:
        decoded_token = firebase_auth.verify_id_token(res.credentials, clock_skew_seconds=60)
        uid = decoded_token.get("uid")
        email = decoded_token.get("email")
        try:
            user = firebase_auth.get_user(uid)
            custom_claims = user.custom_claims or {}
        except Exception:
            custom_claims = {}
        return CurrentUser(
            uid=uid, email=email or "",
            role=custom_claims.get("role", "patient"),
            hospital_id=custom_claims.get("hospital_id")
        )
    except:
        return None

# ============= ROUTES =============

@router.post("/register/doctor", response_model=AuthResponse)
async def register_doctor(data: DoctorRegistration):
    try:
        user = firebase_auth.create_user(
            email=data.email,
            password=data.password,
            display_name=data.full_name
        )

        # 🔹 Set custom claims so the role is embedded in the token
        firebase_auth.set_custom_user_claims(user.uid, {
            "role": "doctor",
            "hospital_id": data.hospital_id
        })

        doctor_data = {
            'name': data.full_name,
            'full_name': data.full_name,
            'email': data.email,
            'license': data.medical_license,
            'hospital_affiliation': data.hospital_id,
            'specialization': data.specialization,
            'phone': data.phone,
            'role': 'doctor',
            'created_at': firestore.SERVER_TIMESTAMP
        }

        firebase_helper.create_document('doctors', user.uid, doctor_data)

        # 🔹 Handle potential bytes output from create_custom_token
        token_res = firebase_auth.create_custom_token(user.uid)
        token = token_res.decode('utf-8') if isinstance(token_res, bytes) else token_res

        return AuthResponse(
            uid=user.uid, email=data.email, role=UserRole.DOCTOR,
            token=token, full_name=data.full_name, hospital_id=data.hospital_id
        )
    except Exception as e:
        print(f"Registration Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/register/patient", response_model=AuthResponse)
async def register_patient(data: PatientRegistration):
    try:
        user = firebase_auth.create_user(
            email=data.email,
            password=data.password,
            display_name=data.full_name
        )

        # 🔹 Set role in custom claims
        firebase_auth.set_custom_user_claims(user.uid, {"role": "patient"})

        patient_data = {
            'name': data.full_name,
            'full_name': data.full_name,
            'age': 0, # Required by firestore rules
            'preferred_hospital': 'unknown', # Required by firestore rules
            'symptom_description': 'Registered User', # Required by firestore rules
            'email': data.email,
            'date_of_birth': data.date_of_birth,
            'phone': data.phone,
            'gender': data.gender,
            'role': 'patient',
            'created_at': firestore.SERVER_TIMESTAMP
        }

        firebase_helper.create_document('patients', user.uid, patient_data)
        
        # 🔹 Handle potential bytes output
        token_res = firebase_auth.create_custom_token(user.uid)
        token = token_res.decode('utf-8') if isinstance(token_res, bytes) else token_res

        return AuthResponse(
            uid=user.uid, email=data.email, role=UserRole.PATIENT,
            token=token, full_name=data.full_name
        )
    except Exception as e:
        print(f"Patient Registration Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/login", response_model=AuthResponse)
async def login(data: LoginRequest):
    try:
        user = firebase_auth.get_user_by_email(data.email)

        # Check profiles
        doctor = firebase_helper.get_doctor_by_uid(user.uid)
        patient = firebase_helper.get_patient_by_uid(user.uid)

        if doctor:
            role, name, hid = UserRole.DOCTOR, doctor.get('name', doctor.get('full_name')), doctor.get('hospital_affiliation', doctor.get('hospital_id'))
        elif patient:
            role, name, hid = UserRole.PATIENT, patient.get('name', patient.get('full_name')), None
        else:
            raise HTTPException(status_code=404, detail="Profile missing")

        token_res = firebase_auth.create_custom_token(user.uid)
        token = token_res.decode('utf-8') if isinstance(token_res, bytes) else token_res
        
        return AuthResponse(uid=user.uid, email=user.email, role=role, token=token, full_name=name, hospital_id=hid)
    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=401, detail=f"Authentication failed: {str(e)}")