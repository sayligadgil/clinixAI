# app/models/schemas.py
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum

# ============= ENUMS =============
class UserRole(str, Enum):
    DOCTOR = "doctor"
    PATIENT = "patient"

class ConsultationStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    ESCALATED = "escalated"
    ALERTED = "alerted"
    REVIEWED = "reviewed"

class AlertStatus(str, Enum):
    UNREAD = "unread"
    READ = "read"
    RESOLVED = "resolved"

class RiskLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

# ============= AUTH SCHEMAS =============
class DoctorRegistration(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str
    medical_license: str
    hospital_id: str = Field(..., pattern="^(h001|h002|h003|apollo_jh|kims_begumpet|continental_gachibowli)$")
    specialization: str
    phone: Optional[str] = None

    @validator('hospital_id')
    def validate_hospital(cls, v):
        valid_hospitals = ['h001', 'h002', 'h003', 'apollo_jh', 'kims_begumpet', 'continental_gachibowli']
        if v not in valid_hospitals:
            raise ValueError(f'Hospital ID must be one of {valid_hospitals}')
        return v

class PatientRegistration(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    full_name: str
    date_of_birth: str
    phone: str
    gender: str
    address: Optional[str] = None
    emergency_contact: Optional[str] = None

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class AuthResponse(BaseModel):
    uid: str
    email: str
    role: UserRole
    token: str
    full_name: str
    hospital_id: Optional[str] = None

# ============= CONSULTATION SCHEMAS =============
class SymptomInput(BaseModel):
    name: str
    severity: int = Field(..., ge=1, le=10)
    duration_days: int
    description: Optional[str] = None

class VitalSigns(BaseModel):
    temperature: Optional[float] = None
    blood_pressure_systolic: Optional[int] = None
    blood_pressure_diastolic: Optional[int] = None
    heart_rate: Optional[int] = None
    respiratory_rate: Optional[int] = None
    oxygen_saturation: Optional[float] = None

class PatientIntake(BaseModel):
    patient_uid: Optional[str] = None
    full_name: Optional[str] = None
    age: Optional[int] = None
    email: Optional[str] = None
    hospital_id: str
    symptoms: List[SymptomInput]
    description: Optional[str] = None
    vital_signs: Optional[VitalSigns] = None
    medical_history: Optional[List[str]] = None
    current_medications: Optional[List[str]] = None
    allergies: Optional[List[str]] = None

    @validator('symptoms')
    def validate_symptoms(cls, v):
        if len(v) == 0:
            raise ValueError('At least one symptom is required')
        return v

class DiseaseClassification(BaseModel):
    icd10_code: str
    disease_name: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    category: str

class AnomalyDetection(BaseModel):
    is_anomalous: bool
    anomaly_score: float
    anomaly_reasons: List[str]
    risk_level: RiskLevel

class DoctorMatch(BaseModel):
    doctor_uid: str
    doctor_name: str
    specialization: str
    hospital_id: str
    match_score: float
    availability: Optional[str] = None

class Medication(BaseModel):
    name: str
    dosage: str
    frequency: str
    duration_days: int
    instructions: Optional[str] = None

class PrescriptionOutput(BaseModel):
    medications: List[Medication]
    dietary_advice: Optional[List[str]] = None
    lifestyle_recommendations: Optional[List[str]] = None
    follow_up_days: Optional[int] = None
    warning_signs: Optional[List[str]] = None

class ConsultationResponse(BaseModel):
    consultation_id: str
    patient_uid: str
    hospital_id: str
    disease_classification: DiseaseClassification
    anomaly_detection: AnomalyDetection
    matched_doctors: List[DoctorMatch]
    prescription: Optional[PrescriptionOutput] = None
    requires_immediate_attention: bool
    ai_confidence: float
    status: ConsultationStatus
    created_at: datetime
    token: Optional[str] = None  # 🔹 For seamless login after guest intake

# ============= ALERT SCHEMAS =============
class AlertCreate(BaseModel):
    consultation_id: str
    patient_uid: str
    hospital_id: str
    alert_type: str
    severity: RiskLevel
    message: str
    assigned_doctor_uid: Optional[str] = None

class AlertResponse(BaseModel):
    alert_id: str
    consultation_id: str
    patient_uid: str
    patient_name: str
    hospital_id: str
    alert_type: str
    severity: RiskLevel
    message: str
    assigned_doctor_uid: Optional[str] = None
    status: AlertStatus
    created_at: datetime
    resolved_at: Optional[datetime] = None

# ============= ALERT SCHEMAS =============

class AlertRecord(BaseModel):
    alert_id: str
    consultation_id: str
    patient_uid: str
    patient_name: str
    hospital_id: str
    alert_type: str
    severity: RiskLevel
    message: str
    assigned_doctor_uid: Optional[str] = None
    is_resolved: bool = False
    created_at: datetime
    resolved_at: Optional[datetime] = None

# ============= DOCTOR REVIEW SCHEMAS =============
class DoctorReview(BaseModel):
    consultation_id: str
    doctor_uid: str
    diagnosis_confirmed: bool
    final_diagnosis: Optional[str] = None
    prescription_approved: bool
    prescription_modifications: Optional[List[Medication]] = None
    notes: Optional[str] = None
    follow_up_required: bool
    follow_up_date: Optional[str] = None

class DoctorDashboard(BaseModel):
    doctor_uid: str
    doctor_name: str
    specialization: str
    hospital_id: str
    pending_alerts: int
    pending_consultations: int
    alerts: List[AlertResponse]
    recent_consultations: List[Dict[str, Any]]

# ============= RESPONSE WRAPPERS =============
class SuccessResponse(BaseModel):
    success: bool = True
    message: str
    data: Optional[Any] = None

class ErrorResponse(BaseModel):
    success: bool = False
    error: str
    details: Optional[str] = None

# ============= PATIENT SCHEMAS =============
# 🔹 Add this missing class for the router
class PatientProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    gender: Optional[str] = None
    address: Optional[str] = None
    emergency_contact: Optional[str] = None

# Export aliases for the router
SymptomIntakeRequest = PatientIntake
PatientProfile = PatientRegistration
DoctorProfile = DoctorRegistration

class AIAnalysisResult(BaseModel):
    consultation_id: str
    predicted_illness: str
    icd10_code: str
    confidence_score: float
    top_predictions: List[Any]
    requires_doctor_alert: bool
    recommended_specialist: str
    matched_doctor: Optional[Dict[str, Any]] = None
    analysis_notes: str
    status: ConsultationStatus
    token: Optional[str] = None
    patient_uid: Optional[str] = None

    # Frontend CarePathData fields (added for compatibility and robustness)
    matched_doctor_name: Optional[str] = None
    matched_doctor_uid: Optional[str] = None
    recommended_spec: Optional[str] = None
    diagnosis: Optional[str] = None
    confidence: Optional[float] = None
    analysis_detail: Optional[str] = None
    price: Optional[float] = 24.99
    hospital_name: Optional[str] = "Medical Center"

# If these are missing, add basic versions for now to stop the ImportError:
class PaymentOrderRequest(BaseModel):
    patient_uid: str
    consultation_id: str
    amount_inr: float
    currency: str = "INR"

class PaymentVerifyRequest(BaseModel):
    patient_uid: str
    consultation_id: str
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str

class AppointmentStatus(str, Enum):
    SCHEDULED = "scheduled"
    CANCELLED = "cancelled"
    COMPLETED = "completed"

class AppointmentRequest(BaseModel):
    patient_uid: str
    consultation_id: str
    hospital_id: str
    preferred_doctor_uid: Optional[str] = None
    preferred_date: str
    preferred_time: str
    reason: Optional[str] = None

# ============= APPOINTMENT SCHEMAS =============

class AppointmentRecord(BaseModel):
    appointment_id: str
    patient_uid: str
    patient_name: str
    doctor_uid: str
    doctor_name: str
    hospital_id: str
    hospital_name: str
    consultation_id: str
    scheduled_date: str
    scheduled_time: str
    reason: Optional[str] = None
    status: AppointmentStatus
    created_at: datetime
    updated_at: datetime

# ─── ADDITIONAL MISSING SCHEMAS FOR THE ROUTER ───

class PrescriptionRecord(BaseModel):
    id: str
    consultation_id: str
    patient_uid: str
    diagnosis: str
    medications: List[Medication]
    issued_at: datetime

class PaymentOrderResponse(BaseModel):
    id: str
    entity: str
    amount: int
    currency: str
    status: str

# ============= DOCTOR REVIEW SCHEMAS =============

class DoctorReviewRequest(BaseModel):
    """Schema for a doctor reviewing and potentially overriding AI analysis"""
    doctor_uid: str
    notes: Optional[str] = None
    diagnosis_override: Optional[str] = None
    approve_prescription: bool = True

