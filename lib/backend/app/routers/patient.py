"""
app/routers/patient.py
─────────────────────────────────────────────────────────────────────────────
All patient-facing endpoints:
  GET  /patient/profile/{uid}
  PUT  /patient/profile/{uid}
  POST /patient/intake          — submit symptoms → trigger AI analysis
  GET  /patient/consultation/{id}
  GET  /patient/consultations/{uid}
  POST /patient/payment/order   — create Razorpay order
  POST /patient/payment/verify  — verify payment → generate prescription
  GET  /patient/prescription/{id}
  GET  /patient/prescription/{id}/pdf
  POST /patient/appointment     — book appointment
  GET  /patient/appointments/{uid}
  GET  /hospitals               — list hospitals
"""
from __future__ import annotations
import logging
from datetime import datetime, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.responses import Response
from ..ml.doctor_matcher import DoctorMatcher

from app.firebase import (
    get_doc, set_doc, query_collection, add_doc, get_firestore, COLLECTION
)
from app.models.schemas import (
    PatientProfile, PatientProfileUpdate,
    SymptomIntakeRequest, AIAnalysisResult,
    PaymentOrderRequest, PaymentOrderResponse, PaymentVerifyRequest,
    AppointmentRequest, AppointmentRecord, AppointmentStatus,
    PrescriptionRecord, SuccessResponse,
)
from app.services.ai_service import run_ai_analysis, create_prescription
from app.services.payment_service import create_order, verify_payment, confirm_payment
from .auth import require_patient, CurrentUser, get_optional_user
from firebase_admin import auth as firebase_auth
from app.utils.pdf_generator import generate_prescription_pdf

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/patient", tags=["Patient"])


# ── Profile ──────────────────────────────────────────────────────────────────

@router.get("/profile/{uid}")
async def get_patient_profile(uid: str, current_user: CurrentUser = Depends(require_patient)):
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    doc = get_doc(COLLECTION["patients"], uid)
    if not doc:
        raise HTTPException(status_code=404, detail="Patient not found.")
    return doc

@router.put("/profile/{uid}")
async def update_patient_profile(uid: str, update: PatientProfileUpdate,
                                  current_user: CurrentUser = Depends(require_patient)):
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    data = {k: v for k, v in update.model_dump().items() if v is not None}
    data["updated_at"] = datetime.now(timezone.utc).isoformat()
    set_doc(COLLECTION["patients"], uid, data)
    return {"success": True, "updated_fields": list(data.keys())}


# ── Symptom Intake → AI Analysis ─────────────────────────────────────────────

@router.post("/intake", response_model=AIAnalysisResult)
async def submit_intake(
    intake: SymptomIntakeRequest,
    background_tasks: BackgroundTasks,
    current_user: Optional[CurrentUser] = Depends(get_optional_user)
):
    """
    Main patient intake endpoint.
    Supports seamless login: Creates a guest user if not authenticated.
    """
    if not intake.symptoms:
        raise HTTPException(status_code=422, detail="At least one symptom must be selected.")

    # 🔹 SEAMLESS LOGIN LOGIC
    patient_uid = current_user.uid if current_user else intake.patient_uid
    custom_token = None

    if not patient_uid:
        # Create a guest patient record
        guest_data = {
            "name": intake.full_name or "Guest Patient",
            "full_name": intake.full_name or "Guest Patient",
            "age": intake.age or 0,
            "preferred_hospital": intake.hospital_id,
            "symptom_description": intake.description or "Intake",
            "email": intake.email,
            "role": "patient",
            "is_guest": True,
            "created_at": datetime.now(timezone.utc).isoformat()
        }
        # Save to Firestore
        patient_uid = add_doc(COLLECTION["patients"], guest_data)
        
        # Generate Custom Token for the frontend to sign in
        # Custom tokens must be strings. .decode('utf-8') is for older firebase-admin, 
        # newer ones return string.
        try:
            token_bytes = firebase_auth.create_custom_token(patient_uid)
            custom_token = token_bytes.decode('utf-8') if isinstance(token_bytes, bytes) else token_bytes
        except Exception as e:
            logger.error(f"Failed to create custom token: {e}")

    # Ensure intake object has the correct UID for analysis
    intake.patient_uid = patient_uid

    # 🚀 Run REAL AI Logic
    result = await run_ai_analysis(intake)
    
    # 🔹 Attach the token to the result so the frontend can log in
    result.token = custom_token
    result.patient_uid = patient_uid
    
    return result


# ── Consultation Records ──────────────────────────────────────────────────────

@router.get("/consultation/{consultation_id}")
async def get_consultation(consultation_id: str,
                            current_user: CurrentUser = Depends(require_patient)):
    doc = get_doc(COLLECTION["consultations"], consultation_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Consultation not found.")
    if doc["patient_uid"] != current_user.uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    return doc

@router.get("/consultations/{uid}")
async def list_consultations(uid: str, current_user: CurrentUser = Depends(require_patient)):
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    return query_collection(COLLECTION["consultations"],
                            filters=[("patient_uid", "==", uid)],
                            order_by="created_at", limit=20)


# ── Payment ───────────────────────────────────────────────────────────────────

@router.post("/payment/order", response_model=PaymentOrderResponse)
async def create_payment_order(req: PaymentOrderRequest,
                                current_user: CurrentUser = Depends(require_patient)):
    if current_user.uid != req.patient_uid:
        raise HTTPException(status_code=403, detail="UID mismatch.")

    # Verify consultation exists and belongs to this patient
    c = get_doc(COLLECTION["consultations"], req.consultation_id)
    if not c or c["patient_uid"] != req.patient_uid:
        raise HTTPException(status_code=404, detail="Consultation not found.")

    amount_paise = int(req.amount_inr * 100)
    order = create_order(req.consultation_id, req.patient_uid, amount_paise, req.currency)
    return PaymentOrderResponse(**order)


@router.post("/payment/verify")
async def verify_and_generate(req: PaymentVerifyRequest,
                               current_user: CurrentUser = Depends(require_patient)):
    """
    Verifies Razorpay signature → confirms payment → generates prescription.
    """
    if current_user.uid != req.patient_uid:
        raise HTTPException(status_code=403, detail="UID mismatch.")

    if not verify_payment(req.razorpay_order_id, req.razorpay_payment_id, req.razorpay_signature):
        raise HTTPException(status_code=400, detail="Payment signature verification failed.")

    payment_id = confirm_payment(req.razorpay_order_id, req.razorpay_payment_id)
    prescription = await create_prescription(req.consultation_id, payment_id=payment_id)

    return {
        "success": True,
        "prescription_id": prescription.id,
        "session_id": prescription.session_id,
        "diagnosis": prescription.diagnosis,
        "medications_count": len(prescription.medications),
    }


# ── Prescription ──────────────────────────────────────────────────────────────

@router.get("/prescription/{prescription_id}")
async def get_prescription(prescription_id: str,
                            current_user: CurrentUser = Depends(require_patient)):
    doc = get_doc(COLLECTION["prescriptions"], prescription_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Prescription not found.")
    if doc["patient_uid"] != current_user.uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    return doc


@router.get("/prescription/{prescription_id}/pdf")
async def download_prescription_pdf(prescription_id: str,
                                     current_user: CurrentUser = Depends(require_patient)):
    """Returns the prescription as a downloadable PDF."""
    doc = get_doc(COLLECTION["prescriptions"], prescription_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Prescription not found.")
    if doc["patient_uid"] != current_user.uid:
        raise HTTPException(status_code=403, detail="Access denied.")

    pdf_bytes = generate_prescription_pdf(doc)
    filename  = f"clinix_prescription_{prescription_id[:8]}.pdf"
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


# ── Appointments ──────────────────────────────────────────────────────────────

@router.post("/appointment", response_model=dict)
async def book_appointment(req: AppointmentRequest,
                            current_user: CurrentUser = Depends(require_patient)):
    if current_user.uid != req.patient_uid:
        raise HTTPException(status_code=403, detail="UID mismatch.")

    # Find the matched doctor from the consultation
    db = get_firestore()
    c_snap = db.collection(COLLECTION["consultations"]).document(req.consultation_id).get()
    if not c_snap.exists:
        c = {
            "patient_uid": req.patient_uid,
            "matched_doctor_uid": req.preferred_doctor_uid or "doc_ramesh_uid",
            "predicted_illness": req.reason or "General Consultation",
            "confidence_score": 0.85,
            "status": "ai_generated",
            "hospital_id": req.hospital_id,
        }
        db.collection(COLLECTION["consultations"]).document(req.consultation_id).set(c)
    else:
        c = c_snap.to_dict()

    doctor_uid = req.preferred_doctor_uid or c.get("matched_doctor_uid") or "doc_ramesh_uid"
    doctor_doc = get_doc(COLLECTION["doctors"], doctor_uid)
    if not doctor_doc:
        doctor_doc = {
            "full_name": "Dr. Ramesh Babu Katta",
            "specialization": "General Medicine",
            "hospital_affiliation": req.hospital_id,
            "hospital_id": req.hospital_id,
        }
        set_doc(COLLECTION["doctors"], doctor_uid, doctor_doc)

    hospital_doc = db.collection(COLLECTION["hospitals"]).document(req.hospital_id).get()
    hospital_name = hospital_doc.to_dict().get("name", "Partner Hospital") \
        if hospital_doc.exists else "Partner Hospital"

    patient_doc = get_doc(COLLECTION["patients"], req.patient_uid)
    patient_name = patient_doc.get("full_name", "Patient") if patient_doc else "Patient"

    now = datetime.now(timezone.utc).isoformat()
    appt = {
        "patient_uid":      req.patient_uid,
        "patient_name":     patient_name,
        "doctor_uid":       doctor_uid,
        "doctor_name":      doctor_doc.get("full_name", "Doctor"),
        "hospital_id":      req.hospital_id,
        "hospital_name":    hospital_name,
        "consultation_id":  req.consultation_id,
        "scheduled_date":   req.preferred_date,
        "scheduled_time":   req.preferred_time,
        "reason":           req.reason or c.get("predicted_illness", ""),
        "status":           AppointmentStatus.SCHEDULED,
        "created_at":       now,
        "updated_at":       now,
    }
    appt_id = add_doc(COLLECTION["appointments"], appt)

    # Notify patient
    patient_fcm = (patient_doc or {}).get("fcm_token")
    if patient_fcm:
        from app.firebase import send_push
        try:
            send_push(patient_fcm,
                      title="Appointment Confirmed ✅",
                      body=f"Dr. {doctor_doc.get('full_name')} at {hospital_name} — {req.preferred_date} {req.preferred_time}",
                      data={"appointment_id": appt_id, "type": "appointment_confirmed"})
        except Exception as e:
            logger.warning(f"Patient appointment FCM failed: {e}")

    return {"success": True, "appointment_id": appt_id, **appt}


@router.get("/appointments/{uid}")
async def list_appointments(uid: str, current_user: CurrentUser = Depends(require_patient)):
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    return query_collection(COLLECTION["appointments"],
                            filters=[("patient_uid", "==", uid)],
                            order_by="created_at", limit=20)


# ── Hospitals ─────────────────────────────────────────────────────────────────

@router.get("/hospitals")
async def list_hospitals(city: Optional[str] = None):
    """List all registered hospitals, optionally filtered by city."""
    filters = []
    if city:
        filters.append(("city", "==", city))
    return query_collection(COLLECTION["hospitals"], filters=filters, limit=50)
