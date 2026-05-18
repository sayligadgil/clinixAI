# app/ml/prescription_generator.py
from typing import List, Dict, Optional
from ..models.schemas import PrescriptionOutput, Medication, RiskLevel
from ..firebase import get_db

class PrescriptionGenerator:
    """
    Database-driven prescription generator
    Fetches medication recommendations from Firestore based on ICD-10 codes

    NOTE: All prescriptions require doctor review and approval
    """

    def __init__(self):
        self._prescription_cache = None
        self._drug_interaction_cache = None

    def generate_prescription(self,
                             icd10_code: str,
                             patient_symptoms: List[str],
                             risk_level: RiskLevel,
                             allergies: Optional[List[str]] = None,
                             current_medications: Optional[List[str]] = None) -> PrescriptionOutput:
        """
        Generate prescription based on diagnosis

        Args:
            icd10_code: Diagnosed ICD-10 code
            patient_symptoms: List of symptom names
            risk_level: Risk level from anomaly detection
            allergies: Patient allergies
            current_medications: Current medications

        Returns:
            PrescriptionOutput with medications and recommendations
        """

        # High/Critical risk cases should NOT get automated prescriptions
        if risk_level in [RiskLevel.CRITICAL, RiskLevel.HIGH]:
            return PrescriptionOutput(
                medications=[],
                warning_signs=['⚠️ REQUIRES IMMEDIATE DOCTOR REVIEW - HIGH RISK CASE'],
                follow_up_days=1
            )

        # Load prescription rules from database
        if self._prescription_cache is None:
            self._load_prescription_rules()

        # Try to find prescription rule by ICD-10
        prescription_data = self._get_prescription_by_icd10(icd10_code)

        # Fallback to symptom-based prescription
        if not prescription_data or not prescription_data.get('medications'):
            prescription_data = self._get_prescription_by_symptoms(patient_symptoms)

        # Check for drug interactions and allergies
        medications = prescription_data.get('medications', [])

        if allergies:
            medications = self._filter_allergies(medications, allergies)

        if current_medications:
            medications = self._check_drug_interactions(medications, current_medications)

        # Convert to Medication objects
        medication_objects = [
            Medication(
                name=med.get('name'),
                dosage=med.get('dosage'),
                frequency=med.get('frequency'),
                duration_days=med.get('duration_days'),
                instructions=med.get('instructions')
            ) for med in medications
        ]

        return PrescriptionOutput(
            medications=medication_objects,
            dietary_advice=prescription_data.get('dietary_advice'),
            lifestyle_recommendations=prescription_data.get('lifestyle_recommendations'),
            follow_up_days=prescription_data.get('follow_up_days', 7),
            warning_signs=prescription_data.get('warning_signs', [])
        )

    def _load_prescription_rules(self):
        """Load prescription rules from Firestore"""
        try:
            rules = get_db().collection('prescription_rules').stream()
            self._prescription_cache = {}

            for doc in rules:
                data = doc.to_dict()
                icd10_key = doc.id
                self._prescription_cache[icd10_key] = data

            print(f"[OK] Loaded {len(self._prescription_cache)} prescription rules from Firestore")

        except Exception as e:
            print(f"[WARN] Failed to load prescription rules: {str(e)}")
            self._prescription_cache = {}

    def _get_prescription_by_icd10(self, icd10_code: str) -> Optional[Dict]:
        """Find prescription rule matching ICD-10 code"""

        # Exact match
        if icd10_code in self._prescription_cache:
            return self._prescription_cache[icd10_code].copy()

        # Category match (first 3 characters)
        code_prefix = icd10_code[:3]
        if code_prefix in self._prescription_cache:
            return self._prescription_cache[code_prefix].copy()

        # Range match (e.g., J00-J06)
        for rule_code, rule_data in self._prescription_cache.items():
            if '-' in rule_code:
                try:
                    start, end = rule_code.split('-')
                    if start <= code_prefix <= end:
                        return rule_data.copy()
                except:
                    continue

        return None

    def _get_prescription_by_symptoms(self, symptoms: List[str]) -> Dict:
        """
        Generate prescription based on symptoms
        Queries Firestore for symptom-based medication rules
        """
        try:
            # Query symptom-based rules from Firestore
            symptom_rules = get_db().collection('symptom_medications').stream()

            medications = []
            dietary_advice = set()
            warning_signs = set()

            symptom_lower = [s.lower() for s in symptoms]

            for doc in symptom_rules:
                data = doc.to_dict()
                symptom_keyword = data.get('symptom_keyword', '').lower()

                # Check if this symptom keyword matches any patient symptom
                if any(symptom_keyword in s for s in symptom_lower):
                    medications.extend(data.get('medications', []))
                    dietary_advice.update(data.get('dietary_advice', []))
                    warning_signs.update(data.get('warning_signs', []))

            # Remove duplicate medications
            seen = set()
            unique_meds = []
            for med in medications:
                if med['name'] not in seen:
                    seen.add(med['name'])
                    unique_meds.append(med)

            return {
                'medications': unique_meds[:3],  # Max 3 symptomatic meds
                'dietary_advice': list(dietary_advice) or ['Stay hydrated', 'Get adequate rest'],
                'warning_signs': list(warning_signs) or ['Symptoms worsen', 'No improvement in 3 days']
            }

        except Exception as e:
            print(f"[WARN] Error fetching symptom-based prescriptions: {str(e)}")
            # Minimal fallback
            return {
                'medications': [],
                'dietary_advice': ['Stay hydrated', 'Get adequate rest'],
                'warning_signs': ['Consult a doctor if symptoms persist']
            }

    def _filter_allergies(self, medications: List[Dict], allergies: List[str]) -> List[Dict]:
        """
        Remove medications that match patient allergies
        Also checks drug class allergies from database
        """
        if self._drug_interaction_cache is None:
            self._load_drug_interactions()

        allergy_keywords = [a.lower() for a in allergies]
        filtered = []

        for med in medications:
            med_name = med['name'].lower()
            is_allergic = False

            # Direct name match
            if any(allergy in med_name for allergy in allergy_keywords):
                is_allergic = True
                continue

            # Check drug class allergies from database
            for allergy in allergies:
                drug_class_info = self._drug_interaction_cache.get(allergy.lower(), {})
                contraindicated = drug_class_info.get('contraindicated_drugs', [])

                if med['name'] in contraindicated:
                    is_allergic = True
                    break

            if not is_allergic:
                filtered.append(med)

        return filtered

    def _check_drug_interactions(self, new_medications: List[Dict], current_medications: List[str]) -> List[Dict]:
        """
        Check for drug interactions using database
        Removes medications with known interactions
        """
        if self._drug_interaction_cache is None:
            self._load_drug_interactions()

        current_lower = [m.lower() for m in current_medications]
        safe_medications = []

        for med in new_medications:
            has_interaction = False
            med_name = med['name'].lower()

            # Check interactions from database
            interaction_info = self._drug_interaction_cache.get(med_name, {})
            interactions = interaction_info.get('interacts_with', [])

            for current_med in current_lower:
                if current_med in interactions:
                    has_interaction = True
                    print(f"[WARN] Drug interaction detected: {med['name']} + {current_med}")
                    break

            if not has_interaction:
                safe_medications.append(med)

        return safe_medications

    def _load_drug_interactions(self):
        """Load drug interaction data from Firestore"""
        try:
            interactions = get_db().collection('drug_interactions').stream()
            self._drug_interaction_cache = {}

            for doc in interactions:
                data = doc.to_dict()
                drug_name = doc.id.lower()
                self._drug_interaction_cache[drug_name] = data

            print(f"[OK] Loaded {len(self._drug_interaction_cache)} drug interaction records")

        except Exception as e:
            print(f"[WARN] Failed to load drug interactions: {str(e)}")
            self._drug_interaction_cache = {}

    def refresh_cache(self):
        """Force reload of prescription rules and drug interactions"""
        self._prescription_cache = None
        self._drug_interaction_cache = None
        self._load_prescription_rules()
        self._load_drug_interactions()

# Export singleton instance
prescription_generator = PrescriptionGenerator()
generate_prescription = prescription_generator.generate_prescription