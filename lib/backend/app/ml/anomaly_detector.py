# app/ml/anomaly_detector.py
from typing import Dict, List, Any, Tuple
import numpy as np
from ..models.schemas import AnomalyDetection, RiskLevel, VitalSigns, SymptomInput
from ..firebase import get_db

class AnomalyDetector:
    """
    Detects unusual patterns in patient symptoms and vital signs
    Uses database-driven thresholds and risk patterns
    """

    def __init__(self):
        self._vital_thresholds = None
        self._risk_patterns = None

    def detect_anomalies(self,
                        symptoms: List[SymptomInput],
                        vital_signs: VitalSigns = None,
                        medical_history: List[str] = None) -> AnomalyDetection:
        """
        Main anomaly detection pipeline
        """
        # Load thresholds from database
        if self._vital_thresholds is None:
            self._load_vital_thresholds()

        if self._risk_patterns is None:
            self._load_risk_patterns()

        anomaly_reasons = []
        anomaly_score = 0.0

        # 1. Check vital signs
        if vital_signs:
            vital_anomalies, vital_score = self._check_vital_signs(vital_signs)
            anomaly_reasons.extend(vital_anomalies)
            anomaly_score = max(anomaly_score, vital_score)

        # 2. Check symptom severity
        severity_anomalies, severity_score = self._check_symptom_severity(symptoms)
        anomaly_reasons.extend(severity_anomalies)
        anomaly_score = max(anomaly_score, severity_score)

        # 3. Check high-risk symptom combinations (from database)
        combo_anomalies, combo_score = self._check_symptom_combinations(symptoms)
        anomaly_reasons.extend(combo_anomalies)
        anomaly_score = max(anomaly_score, combo_score)

        # 4. Check symptom duration
        duration_anomalies = self._check_symptom_duration(symptoms)
        anomaly_reasons.extend(duration_anomalies)

        # 5. Check medical history risk factors
        if medical_history:
            history_anomalies, history_score = self._check_medical_history(medical_history, symptoms)
            anomaly_reasons.extend(history_anomalies)
            anomaly_score = max(anomaly_score, history_score)

        # Determine risk level
        risk_level = self._calculate_risk_level(anomaly_score)

        return AnomalyDetection(
            is_anomalous=len(anomaly_reasons) > 0,
            anomaly_score=round(anomaly_score, 2),
            anomaly_reasons=anomaly_reasons,
            risk_level=risk_level
        )

    def _load_vital_thresholds(self):
        """Load vital sign thresholds from Firestore"""
        try:
            thresholds_doc = get_db().collection('vital_thresholds').document('default').get()

            if thresholds_doc.exists:
                self._vital_thresholds = thresholds_doc.to_dict()
                print("[OK] Loaded vital sign thresholds from Firestore")
            else:
                # Create default thresholds if not exist
                self._vital_thresholds = self._get_default_vital_thresholds()
                get_db().collection('vital_thresholds').document('default').set(self._vital_thresholds)
                print("[INFO] Created default vital thresholds in Firestore")

        except Exception as e:
            print(f"[WARN] Failed to load vital thresholds: {str(e)}")
            self._vital_thresholds = self._get_default_vital_thresholds()

    def _get_default_vital_thresholds(self) -> Dict:
        """Default vital sign thresholds as fallback"""
        return {
            'temperature': {'low': 35.0, 'high': 39.5, 'critical_high': 41.0},
            'bp_systolic': {'low': 90, 'high': 140, 'critical_high': 180},
            'bp_diastolic': {'low': 60, 'high': 90, 'critical_high': 120},
            'heart_rate': {'low': 50, 'high': 100, 'critical_high': 130},
            'respiratory_rate': {'low': 12, 'high': 20, 'critical_high': 30},
            'oxygen_saturation': {'critical_low': 90, 'low': 95}
        }

    def _load_risk_patterns(self):
        """Load high-risk symptom combinations from Firestore"""
        try:
            patterns = get_db().collection('risk_patterns').stream()
            self._risk_patterns = []

            for doc in patterns:
                data = doc.to_dict()
                self._risk_patterns.append({
                    'symptoms': data.get('symptoms', []),
                    'condition': data.get('condition', ''),
                    'risk_score': data.get('risk_score', 0.9)
                })

            print(f"[OK] Loaded {len(self._risk_patterns)} risk patterns from Firestore")

        except Exception as e:
            print(f"[WARN] Failed to load risk patterns: {str(e)}")
            self._risk_patterns = self._get_default_risk_patterns()

    def _get_default_risk_patterns(self) -> List[Dict]:
        """Default high-risk patterns as fallback"""
        return [
            {'symptoms': ['chest pain', 'shortness of breath'], 'condition': 'Cardiac Emergency', 'risk_score': 0.95},
            {'symptoms': ['severe headache', 'vision changes', 'confusion'], 'condition': 'Neurological Emergency', 'risk_score': 0.9},
            {'symptoms': ['high fever', 'stiff neck', 'sensitivity to light'], 'condition': 'Meningitis Risk', 'risk_score': 0.95},
            {'symptoms': ['abdominal pain', 'vomiting blood'], 'condition': 'GI Emergency', 'risk_score': 0.9},
            {'symptoms': ['difficulty breathing', 'wheezing', 'chest tightness'], 'condition': 'Respiratory Emergency', 'risk_score': 0.85}
        ]

    def _check_vital_signs(self, vital_signs: VitalSigns) -> Tuple[List[str], float]:
        """Check for abnormal vital signs using database thresholds"""
        anomalies = []
        max_score = 0.0

        # Temperature
        if vital_signs.temperature:
            temp_thresholds = self._vital_thresholds.get('temperature', {})
            if vital_signs.temperature >= temp_thresholds.get('critical_high', 41.0):
                anomalies.append(f"Critical high fever ({vital_signs.temperature}°C)")
                max_score = max(max_score, 0.95)
            elif vital_signs.temperature >= temp_thresholds.get('high', 39.5):
                anomalies.append(f"High fever ({vital_signs.temperature}°C)")
                max_score = max(max_score, 0.7)
            elif vital_signs.temperature <= temp_thresholds.get('low', 35.0):
                anomalies.append(f"Hypothermia risk ({vital_signs.temperature}°C)")
                max_score = max(max_score, 0.8)

        # Blood Pressure
        if vital_signs.blood_pressure_systolic and vital_signs.blood_pressure_diastolic:
            bp_sys_thresholds = self._vital_thresholds.get('bp_systolic', {})
            if vital_signs.blood_pressure_systolic >= bp_sys_thresholds.get('critical_high', 180):
                anomalies.append(f"Hypertensive crisis (BP: {vital_signs.blood_pressure_systolic}/{vital_signs.blood_pressure_diastolic})")
                max_score = max(max_score, 0.95)
            elif vital_signs.blood_pressure_systolic <= bp_sys_thresholds.get('low', 90):
                anomalies.append(f"Hypotension detected (BP: {vital_signs.blood_pressure_systolic}/{vital_signs.blood_pressure_diastolic})")
                max_score = max(max_score, 0.75)

        # Heart Rate
        if vital_signs.heart_rate:
            hr_thresholds = self._vital_thresholds.get('heart_rate', {})
            if vital_signs.heart_rate >= hr_thresholds.get('critical_high', 130):
                anomalies.append(f"Severe tachycardia ({vital_signs.heart_rate} bpm)")
                max_score = max(max_score, 0.9)
            elif vital_signs.heart_rate <= hr_thresholds.get('low', 50):
                anomalies.append(f"Bradycardia detected ({vital_signs.heart_rate} bpm)")
                max_score = max(max_score, 0.7)

        # Oxygen Saturation
        if vital_signs.oxygen_saturation:
            o2_thresholds = self._vital_thresholds.get('oxygen_saturation', {})
            if vital_signs.oxygen_saturation <= o2_thresholds.get('critical_low', 90):
                anomalies.append(f"Critical hypoxemia (SpO2: {vital_signs.oxygen_saturation}%)")
                max_score = max(max_score, 0.95)
            elif vital_signs.oxygen_saturation <= o2_thresholds.get('low', 95):
                anomalies.append(f"Low oxygen saturation (SpO2: {vital_signs.oxygen_saturation}%)")
                max_score = max(max_score, 0.75)

        # Respiratory Rate
        if vital_signs.respiratory_rate:
            rr_thresholds = self._vital_thresholds.get('respiratory_rate', {})
            if vital_signs.respiratory_rate >= rr_thresholds.get('critical_high', 30):
                anomalies.append(f"Severe tachypnea ({vital_signs.respiratory_rate} breaths/min)")
                max_score = max(max_score, 0.85)

        return anomalies, max_score

    def _check_symptom_severity(self, symptoms: List[SymptomInput]) -> Tuple[List[str], float]:
        """Check for high-severity symptoms"""
        anomalies = []
        max_score = 0.0

        severe_symptoms = [s for s in symptoms if s.severity >= 8]
        if severe_symptoms:
            for symptom in severe_symptoms:
                anomalies.append(f"Severe {symptom.name} (severity: {symptom.severity}/10)")
                max_score = max(max_score, 0.8)

        # Multiple moderate symptoms
        moderate_symptoms = [s for s in symptoms if 5 <= s.severity < 8]
        if len(moderate_symptoms) >= 4:
            anomalies.append(f"Multiple moderate symptoms ({len(moderate_symptoms)} symptoms)")
            max_score = max(max_score, 0.65)

        return anomalies, max_score

    def _check_symptom_combinations(self, symptoms: List[SymptomInput]) -> Tuple[List[str], float]:
        """Check for dangerous symptom combinations from database"""
        anomalies = []
        max_score = 0.0

        symptom_names = [s.name.lower() for s in symptoms]

        for risk_pattern in self._risk_patterns:
            required_symptoms = risk_pattern['symptoms']

            # Check if all required symptoms are present
            if all(any(req in symptom for symptom in symptom_names) for req in required_symptoms):
                anomalies.append(f"High-risk pattern detected: {risk_pattern['condition']}")
                max_score = max(max_score, risk_pattern.get('risk_score', 0.9))

        return anomalies, max_score

    def _check_symptom_duration(self, symptoms: List[SymptomInput]) -> List[str]:
        """Check for concerning symptom duration"""
        anomalies = []

        # Acute severe symptoms (< 3 days but high severity)
        acute_severe = [s for s in symptoms if s.duration_days <= 3 and s.severity >= 8]
        if acute_severe:
            anomalies.append(f"Acute onset of severe symptoms")

        # Chronic symptoms (> 30 days)
        chronic = [s for s in symptoms if s.duration_days > 30]
        if chronic:
            anomalies.append(f"Chronic symptoms present (>30 days)")

        return anomalies

    def _check_medical_history(self, medical_history: List[str], symptoms: List[SymptomInput]) -> Tuple[List[str], float]:
        """Check for high-risk history + symptom combinations"""
        anomalies = []
        max_score = 0.0

        history_lower = [h.lower() for h in medical_history]
        symptom_names = [s.name.lower() for s in symptoms]

        # Cardiac history + chest symptoms
        if any('cardiac' in h or 'heart' in h for h in history_lower):
            if any('chest' in s or 'pain' in s for s in symptom_names):
                anomalies.append("Cardiac history with chest symptoms")
                max_score = max(max_score, 0.85)

        # Diabetes + infection symptoms
        if any('diabetes' in h for h in history_lower):
            if any('fever' in s or 'infection' in s for s in symptom_names):
                anomalies.append("Diabetes with infection symptoms")
                max_score = max(max_score, 0.7)

        # Immunocompromised + fever
        if any('immunocompromised' in h or 'hiv' in h or 'cancer' in h for h in history_lower):
            if any('fever' in s for s in symptom_names):
                anomalies.append("Immunocompromised patient with fever")
                max_score = max(max_score, 0.8)

        return anomalies, max_score

    def _calculate_risk_level(self, anomaly_score: float) -> RiskLevel:
        """Convert anomaly score to risk level"""
        if anomaly_score >= 0.9:
            return RiskLevel.CRITICAL
        elif anomaly_score >= 0.7:
            return RiskLevel.HIGH
        elif anomaly_score >= 0.4:
            return RiskLevel.MEDIUM
        else:
            return RiskLevel.LOW

    def refresh_cache(self):
        """Force reload of thresholds and patterns from database"""
        self._vital_thresholds = None
        self._risk_patterns = None
        self._load_vital_thresholds()
        self._load_risk_patterns()

# Export singleton instance
anomaly_detector = AnomalyDetector()