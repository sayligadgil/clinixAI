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
        Generate prescription based on symptoms.
        First tries Firestore, then falls back to built-in medication rules.
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
                if any(symptom_keyword in s for s in symptom_lower):
                    medications.extend(data.get('medications', []))
                    dietary_advice.update(data.get('dietary_advice', []))
                    warning_signs.update(data.get('warning_signs', []))

            # If Firestore had data, use it
            if medications:
                seen = set()
                unique_meds = []
                for med in medications:
                    if med['name'] not in seen:
                        seen.add(med['name'])
                        unique_meds.append(med)
                return {
                    'medications': unique_meds[:4],
                    'dietary_advice': list(dietary_advice) or ['Stay hydrated', 'Get adequate rest'],
                    'warning_signs': list(warning_signs) or ['Symptoms worsen', 'No improvement in 3 days']
                }

        except Exception as e:
            print(f"[WARN] Error fetching symptom-based prescriptions: {str(e)}")

        # Built-in fallback: map symptoms to standard OTC medications
        return self._builtin_symptom_prescription(symptoms)

    def _builtin_symptom_prescription(self, symptoms: List[str]) -> Dict:
        """Built-in medication rules when Firestore has no data."""
        symptom_lower = [s.lower() for s in symptoms]

        BUILTIN_RULES = {
            'fever': {
                'medications': [
                    {'name': 'Paracetamol (Crocin)', 'dosage': '500mg', 'frequency': 'Twice daily', 'duration_days': 5, 'instructions': 'After meals'},
                    {'name': 'Ibuprofen', 'dosage': '400mg', 'frequency': 'Thrice daily if fever > 102°F', 'duration_days': 3, 'instructions': 'With food and water'},
                ],
                'dietary_advice': ['Increase fluid intake', 'Rest adequately', 'Avoid cold drinks'],
                'warning_signs': ['Fever > 104°F', 'Difficulty breathing', 'Rash or skin changes'],
            },
            'cough': {
                'medications': [
                    {'name': 'Dextromethorphan (Benadryl Cough)', 'dosage': '10ml', 'frequency': 'Three times a day', 'duration_days': 5, 'instructions': 'Before bedtime for dry cough'},
                    {'name': 'Ambroxol (Mucosolvan)', 'dosage': '30mg', 'frequency': 'Twice daily', 'duration_days': 5, 'instructions': 'For productive cough with mucus'},
                ],
                'dietary_advice': ['Drink warm water with honey', 'Avoid cold beverages', 'Steam inhalation twice daily'],
                'warning_signs': ['Blood in sputum', 'Difficulty breathing', 'Cough persists > 2 weeks'],
            },
            'cold': {
                'medications': [
                    {'name': 'Cetirizine (Zyrtec)', 'dosage': '10mg', 'frequency': 'Once daily at night', 'duration_days': 5, 'instructions': 'For runny nose and sneezing'},
                    {'name': 'Pseudoephedrine (Sudafed)', 'dosage': '60mg', 'frequency': 'Twice daily', 'duration_days': 3, 'instructions': 'For nasal congestion'},
                ],
                'dietary_advice': ['Vitamin C supplements', 'Warm soups and fluids', 'Rest'],
                'warning_signs': ['High fever', 'Ear pain', 'Persistent symptoms beyond 10 days'],
            },
            'headache': {
                'medications': [
                    {'name': 'Paracetamol (Crocin)', 'dosage': '500mg', 'frequency': 'Every 4–6 hours as needed', 'duration_days': 3, 'instructions': 'Max 4 tablets per day'},
                    {'name': 'Sumatriptan (Imigran)', 'dosage': '50mg', 'frequency': 'Once at onset of migraine', 'duration_days': 1, 'instructions': 'Only if migraine is confirmed'},
                ],
                'dietary_advice': ['Stay hydrated', 'Reduce screen time', 'Sleep in a dark, quiet room'],
                'warning_signs': ['Sudden severe headache', 'Headache with stiff neck', 'Vision changes'],
            },
            'vomit': {
                'medications': [
                    {'name': 'Ondansetron (Zofran)', 'dosage': '4mg', 'frequency': 'Every 8 hours', 'duration_days': 3, 'instructions': 'Dissolve under tongue'},
                    {'name': 'ORS (Electral)', 'dosage': '1 sachet in 1L water', 'frequency': 'Sip continuously', 'duration_days': 3, 'instructions': 'To prevent dehydration'},
                ],
                'dietary_advice': ['BRAT diet (Banana, Rice, Applesauce, Toast)', 'Avoid dairy', 'Small sips of water frequently'],
                'warning_signs': ['Blood in vomit', 'Severe abdominal pain', 'Signs of dehydration'],
            },
            'diarrhea': {
                'medications': [
                    {'name': 'Loperamide (Imodium)', 'dosage': '2mg', 'frequency': 'After each loose stool (max 8mg/day)', 'duration_days': 2, 'instructions': 'Symptomatic relief only'},
                    {'name': 'ORS (Electral)', 'dosage': '1 sachet in 1L water', 'frequency': 'Sip continuously', 'duration_days': 3, 'instructions': 'Critical for rehydration'},
                ],
                'dietary_advice': ['BRAT diet', 'Avoid spicy and fatty foods', 'Probiotics like yogurt'],
                'warning_signs': ['Blood in stool', 'Severe abdominal cramps', 'Signs of dehydration'],
            },
            'throat': {
                'medications': [
                    {'name': 'Amoxicillin', 'dosage': '500mg', 'frequency': 'Three times daily', 'duration_days': 7, 'instructions': 'Complete full course even if better'},
                    {'name': 'Benzocaine (Strepsils)', 'dosage': '1 lozenge', 'frequency': 'Every 3 hours as needed', 'duration_days': 5, 'instructions': 'Dissolve slowly in mouth'},
                ],
                'dietary_advice': ['Warm saline gargles', 'Warm fluids', 'Avoid cold drinks'],
                'warning_signs': ['Difficulty swallowing', 'High fever > 101°F', 'Swollen lymph nodes'],
            },
            'stomach': {
                'medications': [
                    {'name': 'Pantoprazole', 'dosage': '40mg', 'frequency': 'Once daily before breakfast', 'duration_days': 7, 'instructions': 'For acidity and gastritis'},
                    {'name': 'Domperidone (Motilium)', 'dosage': '10mg', 'frequency': 'Before meals', 'duration_days': 5, 'instructions': 'For bloating and nausea'},
                ],
                'dietary_advice': ['Avoid spicy, oily food', 'Small frequent meals', 'Avoid lying down after eating'],
                'warning_signs': ['Severe abdominal pain', 'Blood in stool', 'Unexplained weight loss'],
            },
            'body': {
                'medications': [
                    {'name': 'Ibuprofen', 'dosage': '400mg', 'frequency': 'Twice daily', 'duration_days': 5, 'instructions': 'After meals for body aches'},
                    {'name': 'Vitamin D3 (60,000 IU)', 'dosage': '1 tablet', 'frequency': 'Once weekly', 'duration_days': 42, 'instructions': 'For muscle and bone pain'},
                ],
                'dietary_advice': ['Rest and limit physical activity', 'Warm compress on affected areas'],
                'warning_signs': ['Severe joint swelling', 'Inability to walk', 'Fever accompanying pain'],
            },
        }

        matched_meds = []
        matched_advice = set()
        matched_warnings = set()
        used_names = set()

        for keyword, rule in BUILTIN_RULES.items():
            if any(keyword in s for s in symptom_lower):
                for med in rule['medications']:
                    if med['name'] not in used_names:
                        used_names.add(med['name'])
                        matched_meds.append(med)
                matched_advice.update(rule['dietary_advice'])
                matched_warnings.update(rule['warning_signs'])

        # Default if nothing matched
        if not matched_meds:
            matched_meds = [
                {'name': 'Paracetamol (Crocin)', 'dosage': '500mg', 'frequency': 'Twice daily', 'duration_days': 5, 'instructions': 'After meals'},
                {'name': 'Vitamin C', 'dosage': '500mg', 'frequency': 'Once daily', 'duration_days': 7, 'instructions': 'For immune support'},
            ]
            matched_advice = {'Stay hydrated', 'Adequate rest', 'Monitor symptoms'}
            matched_warnings = {'Consult a doctor if symptoms worsen or persist beyond 5 days'}

        return {
            'medications': matched_meds[:4],
            'dietary_advice': list(matched_advice),
            'warning_signs': list(matched_warnings),
            'follow_up_days': 5,
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