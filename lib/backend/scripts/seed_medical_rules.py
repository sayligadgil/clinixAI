# scripts/seed_medical_rules.py
"""
Seed script to populate medical knowledge collections in Firestore
Run this after seeding hospitals and doctors
"""

import firebase_admin
from firebase_admin import credentials, firestore
import sys
import os

# Add parent directory to path to import config
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app.config import get_settings

settings = get_settings()

# Initialize Firebase
cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
firebase_admin.initialize_app(cred, {'projectId': settings.PROJECT_ID})
db = firestore.client()

def seed_specialization_mappings():
    """Seed ICD-10 to specialization mappings"""
    print("📋 Uploading specialization mappings...")

    mappings = [
        {'icd10_range': 'A00-B99', 'specializations': ['Infectious Disease', 'Internal Medicine']},
        {'icd10_range': 'C00-D49', 'specializations': ['Oncology', 'Haematology']},
        {'icd10_range': 'E00-E89', 'specializations': ['Endocrinology', 'Internal Medicine']},
        {'icd10_range': 'F01-F99', 'specializations': ['Psychiatry', 'Neurology']},
        {'icd10_range': 'G00-G99', 'specializations': ['Neurology', 'Neurosurgery']},
        {'icd10_range': 'H00-H59', 'specializations': ['Ophthalmology']},
        {'icd10_range': 'H60-H95', 'specializations': ['ENT']},
        {'icd10_range': 'I00-I99', 'specializations': ['Cardiology', 'Internal Medicine']},
        {'icd10_range': 'J00-J99', 'specializations': ['Pulmonology', 'Internal Medicine']},
        {'icd10_range': 'K00-K95', 'specializations': ['Gastroenterology', 'General Surgery']},
        {'icd10_range': 'L00-L99', 'specializations': ['Dermatology']},
        {'icd10_range': 'M00-M99', 'specializations': ['Orthopaedics']},
        {'icd10_range': 'N00-N99', 'specializations': ['Nephrology', 'Gynaecology']},
        {'icd10_range': 'O00-O9A', 'specializations': ['Obstetrics', 'Gynaecology']},
        {'icd10_range': 'P00-P96', 'specializations': ['Paediatrics']},
        {'icd10_range': 'Q00-Q99', 'specializations': ['Paediatrics', 'Genetics']},
        {'icd10_range': 'R00-R99', 'specializations': ['Emergency Medicine', 'Internal Medicine']},
        {'icd10_range': 'S00-T88', 'specializations': ['Emergency Medicine', 'General Surgery', 'Orthopaedics']},
        {'icd10_range': 'V00-Y99', 'specializations': ['Emergency Medicine']},
        {'icd10_range': 'Z00-Z99', 'specializations': ['Internal Medicine', 'Paediatrics']}
    ]

    for mapping in mappings:
        doc_id = mapping['icd10_range']
        db.collection('specialization_mappings').document(doc_id).set(mapping)
        print(f"   ✅ {doc_id} → {', '.join(mapping['specializations'])}")

    print(f"✅ {len(mappings)} specialization mappings uploaded\n")

def seed_prescription_rules():
    """Seed prescription rules by ICD-10 code"""
    print("💊 Uploading prescription rules...")

    rules = [
        {
            'doc_id': 'J00-J06',
            'data': {
                'condition': 'Acute upper respiratory infections',
                'medications': [
                    {'name': 'Paracetamol', 'dosage': '650mg', 'frequency': 'Every 6 hours', 'duration_days': 5},
                    {'name': 'Cetirizine', 'dosage': '10mg', 'frequency': 'Once daily', 'duration_days': 5}
                ],
                'dietary_advice': ['Drink warm fluids', 'Avoid cold beverages', 'Rest adequately'],
                'warning_signs': ['Difficulty breathing', 'Fever above 103°F for >3 days', 'Chest pain'],
                'follow_up_days': 5
            }
        },
        {
            'doc_id': 'K29',
            'data': {
                'condition': 'Gastritis',
                'medications': [
                    {'name': 'Pantoprazole', 'dosage': '40mg', 'frequency': 'Once daily before breakfast', 'duration_days': 14},
                    {'name': 'Sucralfate', 'dosage': '1g', 'frequency': 'Twice daily', 'duration_days': 14}
                ],
                'dietary_advice': ['Avoid spicy foods', 'Eat smaller meals', 'Avoid alcohol'],
                'lifestyle_recommendations': ['Reduce stress', 'Avoid NSAIDs'],
                'warning_signs': ['Vomiting blood', 'Black stools', 'Severe abdominal pain'],
                'follow_up_days': 14
            }
        },
        {
            'doc_id': 'E11',
            'data': {
                'condition': 'Type 2 Diabetes',
                'medications': [
                    {'name': 'Metformin', 'dosage': '500mg', 'frequency': 'Twice daily with meals', 'duration_days': 30}
                ],
                'dietary_advice': ['Low carbohydrate diet', 'Avoid sugary foods', 'Eat at regular intervals'],
                'lifestyle_recommendations': ['30 minutes daily exercise', 'Monitor blood sugar regularly'],
                'warning_signs': ['Blood sugar <70 or >300', 'Excessive thirst', 'Unexplained weight loss'],
                'follow_up_days': 30
            }
        },
        {
            'doc_id': 'I10',
            'data': {
                'condition': 'Essential hypertension',
                'medications': [
                    {'name': 'Amlodipine', 'dosage': '5mg', 'frequency': 'Once daily', 'duration_days': 30}
                ],
                'dietary_advice': ['Low salt diet', 'DASH diet', 'Limit caffeine'],
                'lifestyle_recommendations': ['Regular exercise', 'Weight management', 'Stress reduction'],
                'warning_signs': ['Severe headache', 'Chest pain', 'Vision changes'],
                'follow_up_days': 14
            }
        },
        {
            'doc_id': 'L02',
            'data': {
                'condition': 'Cutaneous abscess',
                'medications': [
                    {'name': 'Amoxicillin-Clavulanate', 'dosage': '625mg', 'frequency': 'Twice daily', 'duration_days': 7},
                    {'name': 'Ibuprofen', 'dosage': '400mg', 'frequency': 'Every 8 hours as needed', 'duration_days': 5}
                ],
                'warning_signs': ['Spreading redness', 'Fever', 'Increased swelling'],
                'follow_up_days': 7
            }
        },
        {
            'doc_id': 'N39.0',
            'data': {
                'condition': 'Urinary tract infection',
                'medications': [
                    {'name': 'Nitrofurantoin', 'dosage': '100mg', 'frequency': 'Twice daily', 'duration_days': 7}
                ],
                'dietary_advice': ['Drink plenty of water', 'Cranberry juice may help'],
                'warning_signs': ['High fever', 'Back pain', 'Blood in urine'],
                'follow_up_days': 7
            }
        }
    ]

    for rule in rules:
        db.collection('prescription_rules').document(rule['doc_id']).set(rule['data'])
        print(f"   ✅ {rule['doc_id']} — {rule['data']['condition']}")

    print(f"✅ {len(rules)} prescription rules uploaded\n")

def seed_symptom_medications():
    """Seed symptom-based medication rules"""
    print("🩺 Uploading symptom-based medication rules...")

    symptom_rules = [
        {
            'symptom_keyword': 'fever',
            'medications': [
                {'name': 'Paracetamol', 'dosage': '650mg', 'frequency': 'Every 6 hours', 'duration_days': 3}
            ],
            'dietary_advice': ['Stay hydrated', 'Rest well'],
            'warning_signs': ['Fever >103°F', 'Fever lasting >3 days']
        },
        {
            'symptom_keyword': 'pain',
            'medications': [
                {'name': 'Ibuprofen', 'dosage': '400mg', 'frequency': 'Every 8 hours as needed', 'duration_days': 5}
            ],
            'warning_signs': ['Severe pain', 'Pain with swelling']
        },
        {
            'symptom_keyword': 'nausea',
            'medications': [
                {'name': 'Ondansetron', 'dosage': '4mg', 'frequency': 'Twice daily', 'duration_days': 3}
            ],
            'dietary_advice': ['Eat bland foods', 'Small frequent meals'],
            'warning_signs': ['Vomiting blood', 'Dehydration']
        },
        {
            'symptom_keyword': 'cough',
            'medications': [
                {'name': 'Dextromethorphan', 'dosage': '10mg', 'frequency': 'Every 6 hours', 'duration_days': 5}
            ],
            'dietary_advice': ['Warm fluids', 'Honey'],
            'warning_signs': ['Coughing blood', 'Difficulty breathing']
        },
        {
            'symptom_keyword': 'headache',
            'medications': [
                {'name': 'Paracetamol', 'dosage': '500mg', 'frequency': 'Every 6 hours', 'duration_days': 3}
            ],
            'warning_signs': ['Severe sudden headache', 'Headache with vision changes']
        }
    ]

    for rule in symptom_rules:
        db.collection('symptom_medications').add(rule)
        print(f"   ✅ {rule['symptom_keyword']}")

    print(f"✅ {len(symptom_rules)} symptom medication rules uploaded\n")

def seed_drug_interactions():
    """Seed drug interaction and allergy data"""
    print("⚠️  Uploading drug interaction data...")

    interactions = [
        {
            'drug_name': 'metformin',
            'interacts_with': ['alcohol', 'iodinated contrast'],
            'contraindicated_drugs': [],
            'allergy_class': 'biguanides'
        },
        {
            'drug_name': 'amoxicillin',
            'interacts_with': ['methotrexate', 'warfarin'],
            'contraindicated_drugs': [],
            'allergy_class': 'penicillins'
        },
        {
            'drug_name': 'penicillin',
            'interacts_with': ['methotrexate', 'probenecid'],
            'contraindicated_drugs': [],
            'allergy_class': 'penicillins'
        },
        {
            'drug_name': 'ibuprofen',
            'interacts_with': ['aspirin', 'warfarin', 'lithium'],
            'contraindicated_drugs': [],
            'allergy_class': 'nsaids'
        },
        {
            'drug_name': 'amlodipine',
            'interacts_with': ['simvastatin', 'grapefruit'],
            'contraindicated_drugs': [],
            'allergy_class': 'calcium channel blockers'
        }
    ]

    for interaction in interactions:
        drug_name = interaction['drug_name']
        db.collection('drug_interactions').document(drug_name).set(interaction)
        print(f"   ✅ {drug_name}")

    print(f"✅ {len(interactions)} drug interaction records uploaded\n")

def seed_risk_patterns():
    """Seed high-risk symptom combination patterns"""
    print("🚨 Uploading risk patterns...")

    patterns = [
        {
            'symptoms': ['chest pain', 'shortness of breath'],
            'condition': 'Cardiac Emergency',
            'risk_score': 0.95
        },
        {
            'symptoms': ['severe headache', 'vision changes', 'confusion'],
            'condition': 'Neurological Emergency',
            'risk_score': 0.9
        },
        {
            'symptoms': ['high fever', 'stiff neck', 'sensitivity to light'],
            'condition': 'Meningitis Risk',
            'risk_score': 0.95
        },
        {
            'symptoms': ['abdominal pain', 'vomiting blood'],
            'condition': 'GI Emergency',
            'risk_score': 0.9
        },
        {
            'symptoms': ['difficulty breathing', 'wheezing', 'chest tightness'],
            'condition': 'Respiratory Emergency',
            'risk_score': 0.85
        },
        {
            'symptoms': ['severe abdominal pain', 'fever', 'vomiting'],
            'condition': 'Acute Abdomen',
            'risk_score': 0.8
        },
        {
            'symptoms': ['confusion', 'fever', 'rapid heart rate'],
            'condition': 'Sepsis Risk',
            'risk_score': 0.9
        }
    ]

    for pattern in patterns:
        db.collection('risk_patterns').add(pattern)
        print(f"   ✅ {pattern['condition']} (score: {pattern['risk_score']})")

    print(f"✅ {len(patterns)} risk patterns uploaded\n")

def seed_vital_thresholds():
    """Seed vital sign thresholds"""
    print("🌡️  Uploading vital sign thresholds...")

    thresholds = {
        'temperature': {'low': 35.0, 'high': 39.5, 'critical_high': 41.0},
        'bp_systolic': {'low': 90, 'high': 140, 'critical_high': 180},
        'bp_diastolic': {'low': 60, 'high': 90, 'critical_high': 120},
        'heart_rate': {'low': 50, 'high': 100, 'critical_high': 130},
        'respiratory_rate': {'low': 12, 'high': 20, 'critical_high': 30},
        'oxygen_saturation': {'critical_low': 90, 'low': 95}
    }

    db.collection('vital_thresholds').document('default').set(thresholds)
    print("   ✅ Default vital thresholds set")
    print(f"✅ Vital thresholds uploaded\n")

if __name__ == "__main__":
    print("═══════════════════════════════════════════════════════")
    print("🏥 CLINIX AI — Medical Knowledge Seeder")
    print("═══════════════════════════════════════════════════════\n")
    print(f"✅ Connected to Firestore project: {settings.PROJECT_ID}\n")

    try:
        seed_specialization_mappings()
        seed_prescription_rules()
        seed_symptom_medications()
        seed_drug_interactions()
        seed_risk_patterns()
        seed_vital_thresholds()

        print("═══════════════════════════════════════════════════════")
        print("✅ MEDICAL KNOWLEDGE SEED COMPLETE")
        print("═══════════════════════════════════════════════════════")
        print("Firestore collections populated:")
        print("  • specialization_mappings    (20 documents)")
        print("  • prescription_rules          (6 documents)")
        print("  • symptom_medications         (5 documents)")
        print("  • drug_interactions           (5 documents)")
        print("  • risk_patterns               (7 documents)")
        print("  • vital_thresholds            (1 document)")
        print()

    except Exception as e:
        print(f"\n❌ Error during seeding: {str(e)}")
        import traceback
        traceback.print_exc()