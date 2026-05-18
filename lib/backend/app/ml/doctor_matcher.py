# app/ml/doctor_matcher.py
from typing import List, Dict, Any, Optional
from ..models.schemas import DoctorMatch
from ..firebase import firebase_helper, get_db

class DoctorMatcher:
    """
    Matches patients to appropriate doctors based on:
    - Disease classification (ICD-10)
    - Hospital assignment
    - Doctor specialization (from Firestore)
    - Availability
    """

    def __init__(self):
        self._specialization_cache = None

    def match_doctors(self,
                     hospital_id: str,
                     icd10_code: str,
                     patient_age: int = None,
                     risk_level: str = None) -> List[DoctorMatch]:
        """
        Find the best-matching doctors for a patient

        Args:
            hospital_id: Hospital where consultation is happening
            icd10_code: Predicted disease ICD-10 code
            patient_age: Patient's age (for pediatric cases)
            risk_level: Risk level from anomaly detection

        Returns:
            List of matched doctors, sorted by match score
        """
        # Get all doctors from the hospital
        all_doctors = firebase_helper.get_doctors_by_hospital(hospital_id)

        if not all_doctors:
            return []

        # Determine required specializations from database
        required_specializations = self._get_specializations_for_icd10(icd10_code)

        # Adjust for pediatric cases
        if patient_age is not None and patient_age < 18:
            if 'Paediatrics' not in required_specializations:
                required_specializations.append('Paediatrics')

        # Score each doctor
        doctor_scores = []
        for doctor in all_doctors:
            score = self._calculate_match_score(
                doctor=doctor,
                required_specializations=required_specializations,
                icd10_code=icd10_code,
                risk_level=risk_level
            )

            if score > 0:
                doctor_scores.append({
                    'doctor': doctor,
                    'score': score
                })

        # Sort by score (highest first)
        doctor_scores.sort(key=lambda x: x['score'], reverse=True)

        # Convert to DoctorMatch objects
        matches = []
        for item in doctor_scores[:5]:  # Top 5 matches
            doctor = item['doctor']
            matches.append(DoctorMatch(
                doctor_uid=doctor['id'],
                doctor_name=doctor['full_name'],
                specialization=doctor['specialization'],
                hospital_id=doctor['hospital_id'],
                match_score=round(item['score'], 2),
                availability="Available"  # TODO: Integrate with scheduling system
            ))

        return matches

    def _get_specializations_for_icd10(self, icd10_code: str) -> List[str]:
        """
        Fetch specializations from Firestore based on ICD-10 code
        Uses caching to minimize database reads
        """
        # Load specialization mappings from Firestore (with caching)
        if self._specialization_cache is None:
            self._load_specialization_mappings()

        # Extract the category (first letter for primary category)
        category_prefix = icd10_code[0]
        code_prefix = icd10_code[:3]  # First 3 characters

        # Try exact match first
        if icd10_code in self._specialization_cache:
            return self._specialization_cache[icd10_code].copy()

        # Try 3-character prefix match
        if code_prefix in self._specialization_cache:
            return self._specialization_cache[code_prefix].copy()

        # Try category range match
        for range_key, specializations in self._specialization_cache.items():
            if '-' in range_key:  # It's a range like "A00-B99"
                try:
                    range_start, range_end = range_key.split('-')
                    if range_start[0] <= category_prefix <= range_end[0]:
                        return specializations.copy()
                except:
                    continue

        # Default fallback
        return ['Internal Medicine', 'General Surgery']

    def _load_specialization_mappings(self):
        """Load ICD-10 to specialization mappings from Firestore"""
        try:
            mappings = get_db().collection('specialization_mappings').stream()
            self._specialization_cache = {}

            for doc in mappings:
                data = doc.to_dict()
                icd10_range = data.get('icd10_range')
                specializations = data.get('specializations', [])

                if icd10_range and specializations:
                    self._specialization_cache[icd10_range] = specializations

            print(f"[OK] Loaded {len(self._specialization_cache)} specialization mappings from Firestore")

        except Exception as e:
            print(f"[WARN] Failed to load specialization mappings: {str(e)}")
            # Fallback to minimal hardcoded mappings
            self._specialization_cache = {
                'A00-Z99': ['Internal Medicine']
            }

    def _calculate_match_score(self,
                               doctor: Dict[str, Any],
                               required_specializations: List[str],
                               icd10_code: str,
                               risk_level: str) -> float:
        """
        Calculate how well a doctor matches the consultation needs

        Scoring factors:
        - Exact specialization match: 1.0
        - Related specialization: 0.6
        - Emergency Medicine (for high risk): +0.3
        - General specializations: 0.3
        """
        score = 0.0
        doctor_spec = doctor.get('specialization', '')

        # Exact match
        if doctor_spec in required_specializations:
            score = 1.0
        # Partial match (fuzzy matching)
        elif any(spec.lower() in doctor_spec.lower() for spec in required_specializations):
            score = 0.6
        # Emergency cases
        elif risk_level in ['HIGH', 'CRITICAL'] and doctor_spec == 'Emergency Medicine':
            score = 0.9
        # General specializations
        elif doctor_spec in ['Internal Medicine', 'General Surgery']:
            score = 0.3

        # Boost for Emergency Medicine in high-risk cases
        if risk_level in ['HIGH', 'CRITICAL'] and doctor_spec == 'Emergency Medicine':
            score = min(score + 0.3, 1.0)

        return score

    def get_doctor_by_specialization(self, hospital_id: str, specialization: str) -> List[Dict[str, Any]]:
        """Get all doctors of a specific specialization at a hospital"""
        return firebase_helper.query_documents('doctors', [
            ('hospital_id', '==', hospital_id),
            ('specialization', '==', specialization)
        ])

    def refresh_cache(self):
        """Force reload of specialization mappings from database"""
        self._specialization_cache = None
        self._load_specialization_mappings()

# Export singleton instance
doctor_matcher = DoctorMatcher()