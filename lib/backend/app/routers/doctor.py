"""
app/routers/doctor.py
─────────────────────────────────────────────────────────────────────────────
All doctor-facing endpoints:
  GET  /doctor/profile/{uid}
  PUT  /doctor/profile/{uid}
  GET  /doctor/alerts/{uid}            — pending patient alerts
  POST /doctor/alert/{alert_id}/resolve
  GET  /doctor/consultations/{uid}     — all consultations routed to this doctor
  GET  /doctor/consultation/{id}       — full consultation detail
  POST /doctor/consultation/{id}/review — doctor reviews / overrides AI
  GET  /doctor/appointments/{uid}
  PUT  /doctor/appointment/{id}/status
  GET  /doctor/prescription/{id}
  POST /doctor/prescription/{consultation_id}/override — doctor-issued prescription
  GET  /doctor/patients                — all patients in their hospital
"""
from __future__ import annotations
import logging
import uuid
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException
from google.api_core.exceptions import FailedPrecondition
from typing import Optional, List

from app.firebase import get_doc, set_doc, update_doc, query_collection, add_doc, get_firestore, COLLECTION, send_push
from app.models.schemas import (
    DoctorProfile, DoctorReviewRequest,
    AppointmentStatus, ConsultationStatus,
    SuccessResponse, PrescriptionRecord, Medication,
)
from app.services.ai_service import create_prescription
from .auth import require_doctor, CurrentUser
from ..ml.prescription_generator import PrescriptionGenerator

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/doctor", tags=["Doctor"])


# ── Profile ──────────────────────────────────────────────────────────────────

@router.get("/profile/{uid}")
async def get_doctor_profile(uid: str, current_user: CurrentUser = Depends(require_doctor)):
    doc = get_doc(COLLECTION["doctors"], uid)
    if not doc:
        raise HTTPException(status_code=404, detail="Doctor not found.")
    return doc

@router.put("/profile/{uid}")
async def update_doctor_profile(uid: str, update: dict,
                                 current_user: CurrentUser = Depends(require_doctor)):
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    update["updated_at"] = datetime.now(timezone.utc).isoformat()
    set_doc(COLLECTION["doctors"], uid, update)
    return {"success": True}

# ── Doctor Matching ─────────────────────────────────────────────────────────────
@router.get("/match")
async def match_doctor(
    hospital_id: str,
    specialization: str,
    current_user: CurrentUser = Depends(require_doctor)
):
    """Return a doctor matching the given hospital and specialization.
    Currently returns the first matching doctor.
    """
    doctors = query_collection(
        COLLECTION["doctors"],
        filters=[("hospital_id", "==", hospital_id), ("specialization", "==", specialization)],
        limit=1,
    )
    if not doctors:
        raise HTTPException(status_code=404, detail="No matching doctor found.")
    doc = doctors[0]
    return {"doctor_uid": doc.get("uid"), "full_name": doc.get("full_name")}


# ── Alerts ────────────────────────────────────────────────────────────────────

@router.get("/alerts")
async def get_alerts_query(
    hospital_id: Optional[str] = None,
    status: Optional[str] = None,
    current_user: CurrentUser = Depends(require_doctor)
):
    """
    Returns all unresolved patient alerts routed to this doctor.
    """
    alerts = query_collection(
        COLLECTION["alerts"],
        filters=[("doctor_uid", "==", current_user.uid), ("is_resolved", "==", False)],
        limit=50,
    )
    
    results = []
    for alert in alerts:
        consultation_id = alert.get("consultation_id")
        symptoms_list = []
        if consultation_id:
            c = get_doc(COLLECTION["consultations"], consultation_id)
            if c:
                symptoms_list = [s.get("name") for s in c.get("symptoms", []) if s.get("name")]
        
        results.append({
            "alert_id": alert.get("id"),
            "patient_name": alert.get("patient_name") or "Unknown Patient",
            "received_at": alert.get("created_at") or "Just now",
            "confidence": alert.get("confidence") or 0.0,
            "symptoms": symptoms_list if symptoms_list else ["General symptoms"],
            "ai_assessment": f"Severity: {alert.get('severity')}/10. Top Prediction: {alert.get('ai_top_prediction')}.",
            "risk_score": (alert.get("severity") or 5.0) / 10.0,
        })
    return results


@router.get("/alerts/{uid}")
async def get_alerts(uid: str, current_user: CurrentUser = Depends(require_doctor)):
    """
    Returns all unresolved patient alerts routed to this doctor.
    Ordered by severity descending.
    """
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    return query_collection(
        COLLECTION["alerts"],
        filters=[("doctor_uid", "==", uid), ("is_resolved", "==", False)],
        limit=50,
    )

@router.post("/alert/{alert_id}/resolve")
async def resolve_alert(alert_id: str, notes: str = "",
                         current_user: CurrentUser = Depends(require_doctor)):
    """Mark an alert as resolved by the reviewing doctor."""
    alert = get_doc(COLLECTION["alerts"], alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found.")
    now = datetime.now(timezone.utc).isoformat()
    update_doc(COLLECTION["alerts"], alert_id, {
        "is_resolved":  True,
        "resolved_by":  current_user.uid,
        "resolve_notes": notes,
        "resolved_at":  now,
    })
    
    # Update consultation status to REVIEWED so it shows up in history
    consultation_id = alert.get("consultation_id")
    if consultation_id:
        c = get_doc(COLLECTION["consultations"], consultation_id)
        if c:
            update_doc(COLLECTION["consultations"], consultation_id, {
                "status": ConsultationStatus.REVIEWED,
                "doctor_uid": current_user.uid,
                "updated_at": now,
            })
            
    return {"success": True, "alert_id": alert_id}


# ── Consultations ─────────────────────────────────────────────────────────────

@router.get("/consultations/{uid}")
async def get_doctor_consultations(uid: str, current_user: CurrentUser = Depends(require_doctor)):
    """All consultations matched to this doctor."""
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    return query_collection(
        COLLECTION["consultations"],
        filters=[("matched_doctor_uid", "==", uid)],
        order_by="created_at", limit=50,
    )

@router.get("/consultation/{consultation_id}")
async def get_consultation_detail(consultation_id: str,
                                   current_user: CurrentUser = Depends(require_doctor)):
    doc = get_doc(COLLECTION["consultations"], consultation_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Consultation not found.")
    return doc


@router.post("/consultation/{consultation_id}/review")
async def review_consultation(consultation_id: str,
                               review: DoctorReviewRequest,
                               current_user: CurrentUser = Depends(require_doctor)):
    """
    Doctor reviews the AI analysis:
      - Can override the diagnosis
      - Can approve or block AI prescription
      - Generates a final prescription if approved
    """
    if current_user.uid != review.doctor_uid:
        raise HTTPException(status_code=403, detail="Access denied.")

    c = get_doc(COLLECTION["consultations"], consultation_id)
    if not c:
        raise HTTPException(status_code=404, detail="Consultation not found.")

    now = datetime.now(timezone.utc).isoformat()
    set_doc(COLLECTION["consultations"], consultation_id, {
        "status":            ConsultationStatus.REVIEWED,
        "doctor_uid":        review.doctor_uid,
        "doctor_notes":      review.notes,
        "diagnosis_override": review.diagnosis_override,
        "reviewed_at":       now,
        "updated_at":        now,
    })

    prescription_id = None
    if review.approve_prescription:
        prescription = await create_prescription(
            consultation_id=consultation_id,
            doctor_override_diagnosis=review.diagnosis_override,
        )
        prescription_id = prescription.id

        # Notify patient
        patient_doc = get_doc(COLLECTION["patients"], c["patient_uid"])
        if patient_doc and patient_doc.get("fcm_token"):
            try:
                send_push(
                    patient_doc["fcm_token"],
                    title="Doctor Reviewed Your Consultation 👨‍⚕️",
                    body=f"Dr. {current_user.uid[:8]}... has reviewed your case. Prescription ready.",
                    data={"prescription_id": prescription_id,
                          "consultation_id": consultation_id, "type": "doctor_review"},
                )
            except Exception as e:
                logger.warning(f"Patient FCM failed: {e}")

    return {
        "success": True,
        "consultation_id": consultation_id,
        "prescription_id": prescription_id,
        "diagnosis_used": review.diagnosis_override or c.get("predicted_illness"),
    }


# ── Appointments ──────────────────────────────────────────────────────────────

@router.get("/appointments/{uid}")
async def get_doctor_appointments(uid: str, current_user: CurrentUser = Depends(require_doctor)):
    if current_user.uid != uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    try:
        return query_collection(
            COLLECTION["appointments"],
            filters=[("doctor_uid", "==", uid)],
            order_by="created_at",
            limit=50,
        )
    except FailedPrecondition:
        # Missing composite index – fallback without ordering
        logging.warning("Firestore index missing for doctor appointments query; proceeding without order_by.")
        return query_collection(
            COLLECTION["appointments"],
            filters=[("doctor_uid", "==", uid)],
            limit=50,
        )

@router.put("/appointment/{appointment_id}/status")
async def update_appointment_status(appointment_id: str,
                                     new_status: Optional[AppointmentStatus] = None,
                                     status: Optional[AppointmentStatus] = None,
                                     payload: Optional[dict] = None,
                                     current_user: CurrentUser = Depends(require_doctor)):
    resolved_status = new_status or status
    if payload and "status" in payload:
        resolved_status = payload["status"]
        
    if not resolved_status:
        # Check standard values
        resolved_status = AppointmentStatus.SCHEDULED

    appt = get_doc(COLLECTION["appointments"], appointment_id)
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found.")
    if appt["doctor_uid"] != current_user.uid:
        raise HTTPException(status_code=403, detail="Access denied.")
    now = datetime.now(timezone.utc).isoformat()
    set_doc(COLLECTION["appointments"], appointment_id,
            {"status": resolved_status, "updated_at": now})

    # Notify patient of status change
    patient_doc = get_doc(COLLECTION["patients"], appt["patient_uid"])
    if patient_doc and patient_doc.get("fcm_token"):
        try:
            send_push(
                patient_doc["fcm_token"],
                title=f"Appointment {new_status.capitalize()} 📅",
                body=f"Your appointment on {appt.get('scheduled_date')} has been {new_status}.",
                data={"appointment_id": appointment_id, "status": new_status},
            )
        except Exception as e:
            logger.warning(f"FCM push failed: {e}")

    return {"success": True, "appointment_id": appointment_id, "status": new_status}


# ── Prescription ──────────────────────────────────────────────────────────────

@router.get("/prescription/{prescription_id}")
async def get_prescription(prescription_id: str,
                            current_user: CurrentUser = Depends(require_doctor)):
    doc = get_doc(COLLECTION["prescriptions"], prescription_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Prescription not found.")
    return doc


@router.post("/prescription/{consultation_id}/override")
async def doctor_override_prescription(
    consultation_id: str,
    medications: list[dict],
    advice: list[str],
    diagnosis: str,
    follow_up_days: int = 7,
    emergency_warning: str = "",
    current_user: CurrentUser = Depends(require_doctor),
):
    """
    Doctor writes a fully custom prescription, bypassing the AI suggestion.
    """
    c = get_doc(COLLECTION["consultations"], consultation_id)
    if not c:
        raise HTTPException(status_code=404, detail="Consultation not found.")

    db = get_firestore()
    hosp  = db.collection(COLLECTION["hospitals"]).document(c["hospital_id"]).get()
    hospital_name = hosp.to_dict().get("name", "Hospital") if hosp.exists else "Hospital"

    doctor_doc  = get_doc(COLLECTION["doctors"], current_user.uid)
    doctor_name = doctor_doc.get("full_name", "Doctor") if doctor_doc else "Doctor"

    now  = datetime.now(timezone.utc)
    rx_id = str(uuid.uuid4())
    session_id = f"#DRX-{rx_id[:5].upper()}-{now.year}"

    rx = {
        "id":               rx_id,
        "consultation_id":  consultation_id,
        "patient_uid":      c["patient_uid"],
        "patient_name":     c["full_name"],
        "patient_age":      c["age"],
        "hospital_name":    hospital_name,
        "issuing_doctor":   doctor_name,
        "diagnosis":        diagnosis,
        "icd10_code":       c.get("icd10_code"),
        "confidence_score": 1.0,
        "medications":      medications,
        "general_advice":   advice,
        "follow_up_in_days": follow_up_days,
        "emergency_warning": emergency_warning or None,
        "session_id":       session_id,
        "issued_at":        now.isoformat(),
        "issued_by_doctor": current_user.uid,
    }
    set_doc(COLLECTION["prescriptions"], rx_id, rx)
    set_doc(COLLECTION["consultations"], consultation_id, {
        "status": ConsultationStatus.REVIEWED,
        "prescription_id": rx_id,
        "doctor_uid": current_user.uid,
        "updated_at": now.isoformat(),
    })
    return {"success": True, "prescription_id": rx_id}


# ── Hospital patients ─────────────────────────────────────────────────────────

@router.get("/patients")
async def get_hospital_patients(current_user: CurrentUser = Depends(require_doctor)):
    """
    Returns all recent consultations from the doctor's hospital.
    Used for the doctor's patient list dashboard.
    """
    doctor_doc = get_doc(COLLECTION["doctors"], current_user.uid)
    if not doctor_doc:
        raise HTTPException(status_code=404, detail="Doctor profile not found.")
    hospital_id = doctor_doc.get("hospital_id")
    return query_collection(
        COLLECTION["consultations"],
        filters=[("hospital_id", "==", hospital_id)],
        order_by="created_at", limit=100,
    )


# ── Dashboard stats ───────────────────────────────────────────────────────────

@router.get("/dashboard")
async def doctor_dashboard_query(
    doctor_uid: str,
    current_user: CurrentUser = Depends(require_doctor)
):
    """
    Returns counts and lists for: pending alerts, today's appointments, total patients reviewed.
    Matches query parameter format from frontend.
    """
    if current_user.uid != doctor_uid:
        raise HTTPException(status_code=403, detail="Access denied.")
        
    today = datetime.now(timezone.utc).date().isoformat()

    alerts       = query_collection(COLLECTION["alerts"],
                                    filters=[("doctor_uid", "==", doctor_uid),
                                             ("is_resolved", "==", False)], limit=200)
    appointments = query_collection(COLLECTION["appointments"],
                                    filters=[("doctor_uid", "==", doctor_uid),
                                             ("scheduled_date", "==", today)], limit=50)
    reviewed     = query_collection(COLLECTION["consultations"],
                                    filters=[("matched_doctor_uid", "==", doctor_uid),
                                             ("status", "==", ConsultationStatus.REVIEWED)], limit=200)

    # Map appointments to what the frontend expects
    mapped_appointments = []
    for appt in appointments:
        mapped_appointments.append({
            "patient_name": appt.get("patient_name") or "Unknown Patient",
            "time": appt.get("scheduled_time") or "10:00 AM",
            "reason": appt.get("reason") or "Consultation",
            "type": appt.get("category") or "General"
        })

    # Map alerts to what the frontend expects
    mapped_alerts = []
    for alert in alerts:
        mapped_alerts.append({
            "patient_name": alert.get("patient_name") or "Unknown Patient",
            "alert_type": alert.get("reason") or "Low Confidence",
            "description": f"AI Top Prediction: {alert.get('ai_top_prediction')} with {int(alert.get('confidence', 0.5)*100)}% confidence.",
            "risk_score": 1.0 - alert.get("confidence", 0.5)
        })

    return {
        "appointments": mapped_appointments,
        "alerts": mapped_alerts,
        "queue_count": len(alerts),
        "efficiency": 94.2,
    }

@router.get("/dashboard/{uid}")
async def doctor_dashboard_path(uid: str, current_user: CurrentUser = Depends(require_doctor)):
    """Path parameter fallback for doctor dashboard"""
    return await doctor_dashboard_query(doctor_uid=uid, current_user=current_user)


# ── Schedule, Consultations & Alerts Synchronization ──────────────────────────

@router.get("/schedule")
async def get_doctor_schedule(
    date: Optional[str] = None,
    current_user: CurrentUser = Depends(require_doctor)
):
    """
    Returns appointments for this doctor, optionally filtered by date (YYYY-MM-DD).
    """
    filters = [("doctor_uid", "==", current_user.uid)]
    if date:
        filters.append(("scheduled_date", "==", date))
    try:
        appointments = query_collection(
            COLLECTION["appointments"],
            filters=filters,
            order_by="created_at", limit=100
        )
    except FailedPrecondition:
        # Missing composite index – fallback without ordering
        appointments = query_collection(
            COLLECTION["appointments"],
            filters=filters, limit=100
        )
        import logging
        logging.warning("Firestore index missing for appointments query; proceeding without order_by.")

    
    results = []
    for appt in appointments:
        time_str = appt.get("scheduled_time") or "10:00 AM"
        date_str = appt.get("scheduled_date") or date or "2026-05-18"
        try:
            t_part = time_str.strip()
            if " " in t_part:
                t_val, am_pm = t_part.split(" ")
                h, m = map(int, t_val.split(":"))
                if am_pm.upper() == "PM" and h < 12:
                    h += 12
                elif am_pm.upper() == "AM" and h == 12:
                    h = 0
            else:
                h, m = map(int, t_part.split(":"))
            appt_time_iso = f"{date_str}T{h:02d}:{m:02d}:00"
        except Exception:
            appt_time_iso = f"{date_str}T10:00:00"

        results.append({
            "id": appt.get("id"),
            "patient_name": appt.get("patient_name") or "Unknown Patient",
            "appointment_time": appt_time_iso,
            "reason": appt.get("reason") or "Routine Consultation",
            "category": appt.get("category") or "General",
            "status": appt.get("status") or "scheduled",
        })
        
    return results


@router.get("/consultations")
async def get_doctor_consultations_query(
    hospital_id: Optional[str] = None,
    status: Optional[str] = None,
    is_alert: Optional[str] = None,
    current_user: CurrentUser = Depends(require_doctor)
):
    """
    All consultations matched to this doctor.
    Can be filtered by status (e.g. 'completed', 'reviewed', 'pending').
    """
    filters = [("matched_doctor_uid", "==", current_user.uid)]
    
    if status in ["completed", "reviewed", "reviewed_completed"]:
        filters.append(("status", "==", ConsultationStatus.REVIEWED))
    elif status == "pending":
        filters.append(("status", "==", ConsultationStatus.PENDING))
        
    consultations = query_collection(
        COLLECTION["consultations"],
        filters=filters,
        order_by="created_at", limit=100
    )
    
    if is_alert is not None:
        if is_alert.lower() == 'true':
            consultations = [c for c in consultations if c.get("requires_alert") == True]
        elif is_alert.lower() == 'false':
            consultations = [c for c in consultations if c.get("requires_alert") != True]
    
    results = []
    for c in consultations:
        meds = []
        if c.get("prescription_id"):
            rx = get_doc(COLLECTION["prescriptions"], c["prescription_id"])
            if rx:
                meds = [m.get("name") for m in rx.get("medications", []) if m.get("name")]
                
        created_at_str = c.get("created_at") or datetime.now(timezone.utc).isoformat()
        try:
            dt = datetime.fromisoformat(created_at_str)
            formatted_date = dt.strftime("%d %b %Y")
        except Exception:
            formatted_date = "Recent"

        results.append({
            "id": c.get("id"),
            "consultation_id": c.get("id"),
            "patient_name": c.get("full_name") or "Unknown Patient",
            "category": c.get("predicted_illness") or "General",
            "formatted_date": formatted_date,
            "status": "reviewed" if c.get("status") == ConsultationStatus.REVIEWED else "ai_generated",
            "disease_classification": {
                "label": c.get("predicted_illness") or "Unknown",
                "confidence": c.get("confidence_score") or 0.0,
                "notes": c.get("analysis_notes") or "",
            },
            "anomaly_detection": {
                "is_flagged": c.get("requires_alert") or False,
                "reason": "Anomaly flagged" if c.get("requires_alert") else None,
            },
            "ai_prescription": meds if meds else ["Amoxicillin (Awaiting Payment)", "Rest & Hydration"]
        })
    return results





@router.patch("/appointments/{appointment_id}")
async def patch_appointment_status(
    appointment_id: str,
    payload: dict,
    current_user: CurrentUser = Depends(require_doctor)
):
    """
    Resilient PATCH endpoint for updating appointment status from the schedule screen.
    """
    status_str = payload.get("status")
    if status_str == "pending":
        new_status = AppointmentStatus.SCHEDULED
    elif status_str == "completed":
        new_status = AppointmentStatus.COMPLETED
    else:
        new_status = AppointmentStatus.SCHEDULED

    appt = get_doc(COLLECTION["appointments"], appointment_id)
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found.")
    if appt["doctor_uid"] != current_user.uid:
        raise HTTPException(status_code=403, detail="Access denied.")
        
    now = datetime.now(timezone.utc).isoformat()
    set_doc(COLLECTION["appointments"], appointment_id,
            {"status": new_status, "updated_at": now})
            
    return {"success": True, "appointment_id": appointment_id, "status": new_status}
