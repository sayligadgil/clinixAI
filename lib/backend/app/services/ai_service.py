"""
app/services/ai_service.py
─────────────────────────────────────────────────────────────────────────────
Orchestrates the full AI pipeline for a patient consultation:
  1. Symptom classification    → predicted illness + confidence
  2. Anomaly detection         → flag unusual patterns
  3. Doctor matching           → find best specialist in the patient's hospital
  4. Alert dispatch            → FCM push to doctor if confidence < threshold
  5. Prescription generation   → medications + advice
"""
from __future__ import annotations
import logging
import uuid
from datetime import datetime, timezone
from typing import Optional

from app.config import get_settings
from app.firebase import (
    get_firestore, query_collection, add_doc, set_doc, send_push,
    COLLECTION, firebase_helper
)
from app.ml.symptom_classifier import SymptomClassifier
from app.ml.anomaly_detector import AnomalyDetector
from app.ml.doctor_matcher import DoctorMatcher
from app.ml.prescription_generator import generate_prescription
from app.models.schemas import (
    SymptomIntakeRequest, AIAnalysisResult, ConsultationStatus,
    PrescriptionRecord, AlertRecord, Medication, RiskLevel
)

logger = logging.getLogger(__name__)

# ─── Singleton ML model instances (loaded once at startup) ───────────────────
_classifier:  Optional[SymptomClassifier] = None
_anomaly_det: Optional[AnomalyDetector]   = None
_matcher:     Optional[DoctorMatcher]     = None


def _get_classifier() -> SymptomClassifier:
    global _classifier
    if _classifier is None:
        s = get_settings()
        _classifier = SymptomClassifier(
            model_path=s.SYMPTOM_CLASSIFIER_PATH,
            label_encoder_path=s.LABEL_ENCODER_PATH,
        )
    return _classifier


def _get_anomaly_det() -> AnomalyDetector:
    global _anomaly_det
    if _anomaly_det is None:
        _anomaly_det = AnomalyDetector()
    return _anomaly_det


def _get_matcher() -> DoctorMatcher:
    global _matcher
    if _matcher is None:
        _matcher = DoctorMatcher()
    return _matcher


# ─── Main pipeline ────────────────────────────────────────────────────────────

async def run_ai_analysis(intake: SymptomIntakeRequest) -> AIAnalysisResult:
    """
    Full AI pipeline: intake → analysis result saved to Firestore.
    """
    settings = get_settings()

    # 1. Symptom Classification ────────────────────────────────────────────────
    classifier  = _get_classifier()
    
    symptom_names = [s.name for s in intake.symptoms] if intake.symptoms else []
    overall_severity = max([s.severity for s in intake.symptoms]) if intake.symptoms else 5
    
    clf_result  = classifier.predict(
        selected_symptoms=symptom_names,
        age=intake.age,
        severity=overall_severity,
    )

    predicted_illness = clf_result["predicted_illness"]
    confidence_score  = clf_result["confidence_score"]
    top_predictions   = clf_result["top_predictions"]
    icd10_code        = clf_result["icd10_code"]
    recommended_spec  = clf_result["recommended_specialist"]

    # -----------------------------------------------------------------
    # Sanity checks to avoid illogical low‑confidence predictions
    # -----------------------------------------------------------------
    # 1. Prevent COVID‑19 being suggested for very few mild symptoms
    if predicted_illness.lower().find('covid') != -1 and len(symptom_names) <= 2:
        logger.warning('Low confidence COVID‑19 prediction on minimal symptoms – demoting confidence')
        confidence_score = 0.0
    # 2. Ensure severe cases (severity >= 8) do not get low confidence that
    #    would silently be treated as "OK". Force alert if confidence is low.
    if overall_severity >= 8 and confidence_score < 0.5:
        logger.warning('Severe case with low confidence – forcing alert')
        confidence_score = max(confidence_score, 0.5)
    # -----------------------------------------------------------------

    logger.info(
        f"Classified: {predicted_illness} "
        f"(conf={confidence_score:.2f}, patient={intake.patient_uid})"
    )

    # 2. Anomaly Detection ─────────────────────────────────────────────────────
    anomaly_det   = _get_anomaly_det()
    anomaly_res   = anomaly_det.detect_anomalies(
        symptoms=intake.symptoms,
        vital_signs=intake.vital_signs,
        medical_history=intake.medical_history,
    )
    is_anomaly    = anomaly_res.is_anomalous

    # 3. Determine if doctor alert is needed ──────────────────────────────────
    requires_alert = (
        confidence_score < settings.AI_CONFIDENCE_THRESHOLD
        or is_anomaly
        or overall_severity >= 9
    )

    # 4. Doctor Matching ───────────────────────────────────────────────────────
    matched_doctor: Optional[dict] = None
    matcher = _get_matcher()
    risk_level = anomaly_res.risk_level.value if anomaly_res else "LOW"
    
    # Map frontend hospital ID to seed hospital ID
    id_mapping = {
        "apollo_jh": "h001",
        "kims_begumpet": "h002",
        "continental_gachibowli": "h003"
    }
    mapped_hospital_id = id_mapping.get(intake.hospital_id, intake.hospital_id)
    
    matches = matcher.match_doctors(
        hospital_id=mapped_hospital_id,
        icd10_code=icd10_code,
        patient_age=intake.age,
        risk_level=risk_level
    )
    if matches:
        matched_doctor = firebase_helper.get_doctor_by_uid(matches[0].doctor_uid)

    # 5. Save consultation to Firestore ───────────────────────────────────────
    consultation_id = str(uuid.uuid4())
    now = datetime.now(timezone.utc).isoformat()

    status = ConsultationStatus.ALERTED if requires_alert else ConsultationStatus.COMPLETED

    consultation_doc = {
        "patient_uid":       intake.patient_uid,
        "hospital_id":       intake.hospital_id,
        "full_name":         intake.full_name,
        "age":               intake.age,
        "selected_symptoms": symptom_names,
        "free_text":         intake.description,
        "severity":          overall_severity,
        "known_allergies":   intake.allergies,
        "chronic_conditions":intake.medical_history,
        "predicted_illness": predicted_illness,
        "icd10_code":        icd10_code,
        "confidence_score":  confidence_score,
        "top_predictions":   top_predictions,
        "recommended_specialist": recommended_spec,
        "matched_doctor_uid": matched_doctor.get("id") if matched_doctor else None,
        "requires_alert":    requires_alert,
        "is_anomaly":        is_anomaly,
        "status":            status,
        "created_at":        now,
        "updated_at":        now,
    }
    set_doc(COLLECTION["consultations"], consultation_id, consultation_doc)

    # 6. Send doctor alert via FCM if needed ──────────────────────────────────
    if requires_alert and matched_doctor:
        _dispatch_doctor_alert(
            consultation_id=consultation_id,
            intake=intake,
            confidence_score=confidence_score,
            predicted_illness=predicted_illness,
            doctor=matched_doctor,
            is_anomaly=is_anomaly,
        )

    hospital_mapping = {
        "apollo_jh": "Apollo Hospitals, Jubilee Hills",
        "kims_begumpet": "KIMS-Sunshine Hospitals, Begumpet",
        "continental_gachibowli": "Continental Hospitals, Gachibowli"
    }
    hospital_name = hospital_mapping.get(intake.hospital_id, "Medical Center")
    analysis_notes = (
        "Anomalous symptom pattern detected." if is_anomaly
        else f"Analysis complete with {int(confidence_score*100)}% confidence."
    )

    return AIAnalysisResult(
        consultation_id=consultation_id,
        predicted_illness=predicted_illness,
        icd10_code=icd10_code,
        confidence_score=confidence_score,
        top_predictions=top_predictions,
        requires_doctor_alert=requires_alert,
        recommended_specialist=recommended_spec,
        recommended_spec=recommended_spec,
        matched_doctor=matched_doctor,
        matched_doctor_name=matched_doctor.get("full_name") if matched_doctor else None,
        matched_doctor_uid=matched_doctor.get("id") if matched_doctor else None,
        analysis_notes=analysis_notes,
        status=status,
        diagnosis=predicted_illness,
        confidence=confidence_score,
        analysis_detail=analysis_notes,
        hospital_name=hospital_name,
    )


# ─── Generate & save prescription ────────────────────────────────────────────

async def create_prescription(
    consultation_id: str,
    payment_id: Optional[str] = None,
    doctor_override_diagnosis: Optional[str] = None,
) -> PrescriptionRecord:
    """
    Called after successful payment.
    Fetches the consultation, generates a prescription, saves to Firestore.
    """
    db = get_firestore()
    c_snap = db.collection(COLLECTION["consultations"]).document(consultation_id).get()
    if not c_snap.exists:
        raise ValueError(f"Consultation {consultation_id} not found.")
    c = c_snap.to_dict()

    illness    = doctor_override_diagnosis or c["predicted_illness"]
    now        = datetime.now(timezone.utc)
    session_id = f"#CAI-{consultation_id[:5].upper()}-{now.year}"

    # Fetch hospital name
    hosp_doc = db.collection(COLLECTION["hospitals"]).document(c["hospital_id"]).get()
    hospital_name = hosp_doc.to_dict().get("name", "Partner Hospital") if hosp_doc.exists else "Partner Hospital"

    # Map risk level dynamically
    risk_lvl = RiskLevel.LOW
    confidence = c.get("confidence_score", 1.0)
    
    if confidence < 0.5:
        risk_lvl = RiskLevel.HIGH  # Force high risk to withhold prescription for low confidence cases
    elif c.get("requires_alert"):
        risk_lvl = RiskLevel.HIGH if c.get("severity", 5) >= 8 else RiskLevel.MEDIUM

    # Map symptoms dynamically — stored as selected_symptoms (list of strings)
    symptoms_list = c.get("selected_symptoms", []) or []
    # If it's a list of dicts (legacy format), extract names
    if symptoms_list and isinstance(symptoms_list[0], dict):
        symptoms_list = [s.get("name", "") for s in symptoms_list if s.get("name")]

    # Generate medications via AI / rule-based (synchronously)
    rx_output = generate_prescription(
        icd10_code=c.get("icd10_code", "J00"),
        patient_symptoms=symptoms_list,
        risk_level=risk_lvl,
        allergies=c.get("known_allergies", []),
        current_medications=c.get("chronic_conditions", []),
    )

    meds = rx_output.medications or []

    prescription = PrescriptionRecord(
        id=str(uuid.uuid4()),
        consultation_id=consultation_id,
        patient_uid=c["patient_uid"],
        diagnosis=illness,
        medications=meds,
        issued_at=now,
    )

    # Fetch doctor name from matched doctor
    doctor_name = "AI System"
    doctor_uid = c.get("matched_doctor_uid")
    if doctor_uid:
        doctor_doc = db.collection(COLLECTION["doctors"]).document(doctor_uid).get()
        if doctor_doc.exists:
            doctor_name = doctor_doc.to_dict().get("full_name", "AI System")

    # Build rich prescription dict for Firestore
    rx_dict = {
        **prescription.model_dump(mode="json"),
        "patient_name": c.get("full_name", "Patient"),
        "patient_age": c.get("age", 0),
        "hospital_name": hospital_name,
        "session_id": session_id,
        "issuing_doctor": doctor_name,
        "matched_doctor_uid": doctor_uid,
        "icd10_code": c.get("icd10_code"),
        "confidence_score": c.get("confidence_score", 0.0),
        "general_advice": rx_output.dietary_advice or [],
        "follow_up_in_days": rx_output.follow_up_days or 7,
        "emergency_warning": rx_output.warning_signs[0] if rx_output.warning_signs else None,
    }
    set_doc(COLLECTION["prescriptions"], prescription.id, rx_dict)

    # Update consultation status
    db.collection(COLLECTION["consultations"]).document(consultation_id).update({
        "status": ConsultationStatus.COMPLETED,
        "prescription_id": prescription.id,
        "updated_at": now.isoformat(),
    })

    # Save AI log to doctor dashboard (visible in AI Logs section)
    if doctor_uid:
        ai_log = {
            "type": "ai_prescription",
            "consultation_id": consultation_id,
            "prescription_id": prescription.id,
            "patient_uid": c["patient_uid"],
            "patient_name": c.get("full_name", "Patient"),
            "diagnosis": illness,
            "medications": [m.model_dump(mode="json") if hasattr(m, 'model_dump') else m for m in meds],
            "confidence_score": c.get("confidence_score", 0.0),
            "hospital_name": hospital_name,
            "doctor_uid": doctor_uid,
            "issuing_doctor": doctor_name,
            "is_resolved": False,
            "session_id": session_id,
            "created_at": now.isoformat(),
        }
        add_doc(COLLECTION["alerts"], ai_log)
        logger.info(f"AI log saved for doctor {doctor_uid}, prescription {prescription.id}")

    # Notify patient via FCM
    patient_doc = db.collection(COLLECTION["patients"]).document(c["patient_uid"]).get()
    if patient_doc.exists:
        fcm_token = patient_doc.to_dict().get("fcm_token")
        if fcm_token:
            try:
                send_push(
                    fcm_token,
                    title="Your Prescription is Ready 💊",
                    body=f"Diagnosis: {illness}. Tap to view your digital prescription.",
                    data={"consultation_id": consultation_id,
                          "prescription_id": prescription.id},
                )
            except Exception as e:
                logger.warning(f"FCM notification failed: {e}")

    return prescription


# ─── Internal: dispatch doctor alert ─────────────────────────────────────────

def _dispatch_doctor_alert(
    consultation_id: str,
    intake: SymptomIntakeRequest,
    confidence_score: float,
    predicted_illness: str,
    doctor: dict,
    is_anomaly: bool,
):
    now = datetime.now(timezone.utc).isoformat()

    reason = "low_confidence"
    if is_anomaly:
        reason = "anomaly"
    
    overall_severity = max([s.severity for s in intake.symptoms]) if intake.symptoms else 5
    if overall_severity >= 9:
        reason = "emergency"

    alert = {
        "consultation_id":   consultation_id,
        "patient_uid":       intake.patient_uid,
        "patient_name":      intake.full_name,
        "hospital_id":       intake.hospital_id,
        "severity":          overall_severity,
        "reason":            reason,
        "ai_top_prediction": predicted_illness,
        "confidence":        confidence_score,
        "is_resolved":       False,
        "doctor_uid":        doctor.get("id"),
        "created_at":        now,
    }
    alert_id = add_doc(COLLECTION["alerts"], alert)

    # FCM push to doctor
    fcm_token = doctor.get("fcm_token")
    if fcm_token:
        try:
            send_push(
                fcm_token,
                title="⚠️ Patient Alert — Review Required",
                body=f"{intake.full_name} | {predicted_illness} ({int(confidence_score*100)}% conf) | Severity {overall_severity}/10",
                data={
                    "alert_id":        alert_id,
                    "consultation_id": consultation_id,
                    "type":            "patient_alert",
                },
            )
        except Exception as e:
            logger.warning(f"Doctor FCM push failed: {e}")
