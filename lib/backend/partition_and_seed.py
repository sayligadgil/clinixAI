"""
partition_and_seed.py
─────────────────────────────────────────────────────────────────────────────
Does four things in one script:

1. Defines 3 real Hyderabad hospitals with real addresses + coordinates
2. Partitions the 248 ICD-10 codes into 4 splits:
     • Hospital 1 (Apollo Jubilee Hills) — Chapters I,II,V,VI,IX,XIX  (complex/surgical)
     • Hospital 2 (KIMS Secunderabad)    — Chapters X,XI,XII,XIII,XIV  (internal medicine)
     • Hospital 3 (Continental Gachibowli) — Chapters III,IV,VII,VIII,XV,XVI,XVII (specialty)
     • Test split                         — Chapters XVIII,XXI + random 20% from all

3. Saves 4 JSON files:  hospital_1_icd10.json ... test_icd10.json
4. Saves hospitals_seed.json and doctors_seed.json ready to load into Firestore

Run:  python3 partition_and_seed.py
Then: python3 firestore_loader.py   (requires serviceAccountKey.json)
"""
import json
import random
from pathlib import Path
from icd10_full import get_all

random.seed(42)
OUT = Path("output")
OUT.mkdir(exist_ok=True)

# ═══════════════════════════════════════════════════════════════════════════════
# 1.  HOSPITALS  (real Hyderabad addresses + GPS from Google Maps)
# ═══════════════════════════════════════════════════════════════════════════════
HOSPITALS = [
    {
        "id": "h001",
        "name": "Apollo Hospitals, Jubilee Hills",
        "short_name": "Apollo Jubilee Hills",
        "address": "Road No 72, Opp. Bharatiya Vidya Bhavan School, Film Nagar, Jubilee Hills",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500033",
        "phone": "+91-40-23607777",
        "email": "info.jubileehills@apollohospitals.com",
        "website": "https://www.apollohospitals.com/hospitals/apollo-health-city-jubilee-hills",
        "latitude":  17.4260,
        "longitude": 78.4014,
        "beds": 550,
        "accreditation": ["NABH", "JCI", "NABL"],
        "wait_time_minutes": 20,
        "emergency": True,
        "specialties": [
            "Cardiology", "Oncology", "Neurology", "Neurosurgery",
            "Infectious Disease", "General Surgery", "Emergency Medicine",
            "Psychiatry", "Orthopaedics", "Vascular Surgery"
        ],
        "icd10_chapters_assigned": ["I","II","V","VI","IX","XIX"],
        "focus": "Complex surgical, oncology, cardiac, neurological & infectious cases",
    },
    {
        "id": "h002",
        "name": "KIMS-Sunshine Hospitals, Begumpet",
        "short_name": "KIMS Begumpet",
        "address": "1-112/86, Survey No.5/EE, Beside Andhra Bank, Near RTA Office, Kondapur",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500084",
        "phone": "+91-40-44885000",
        "email": "info@kimssunshine.co.in",
        "website": "https://www.kimssunshine.co.in",
        "latitude":  17.4599,
        "longitude": 78.3674,
        "beds": 350,
        "accreditation": ["NABH"],
        "wait_time_minutes": 10,
        "emergency": True,
        "specialties": [
            "Pulmonology", "Gastroenterology", "Dermatology", "Orthopaedics",
            "Rheumatology", "Urology", "Gynaecology", "ENT", "General Medicine",
            "General Surgery", "Nephrology"
        ],
        "icd10_chapters_assigned": ["X","XI","XII","XIII","XIV"],
        "focus": "Respiratory, digestive, skin, musculoskeletal & genitourinary conditions",
    },
    {
        "id": "h003",
        "name": "Continental Hospitals, Gachibowli",
        "short_name": "Continental Gachibowli",
        "address": "Plot No. 3, Road No. 2, IT & Financial District, Nanakramguda, Gachibowli",
        "city": "Hyderabad",
        "state": "Telangana",
        "pincode": "500032",
        "phone": "+91-40-67000000",
        "email": "info@continentalhospitals.com",
        "website": "https://www.continentalhospitals.com",
        "latitude":  17.4146,
        "longitude": 78.3417,
        "beds": 400,
        "accreditation": ["NABH", "NABL"],
        "wait_time_minutes": 15,
        "emergency": True,
        "specialties": [
            "Haematology", "Endocrinology", "Ophthalmology", "ENT",
            "Obstetrics", "Paediatrics", "Paediatric Cardiology",
            "Nutrition", "Cardiology", "Pulmonology"
        ],
        "icd10_chapters_assigned": ["III","IV","VII","VIII","XV","XVI","XVII"],
        "focus": "Blood, metabolic, eye, ear, maternal, neonatal & congenital conditions",
    },
]

# ═══════════════════════════════════════════════════════════════════════════════
# 2.  DOCTORS  (realistic fictional doctors per hospital, matching specialties)
# ═══════════════════════════════════════════════════════════════════════════════
DOCTORS = [
  # ── Apollo Jubilee Hills (h001) ────────────────────────────────────────────
  {"uid":"doc_apol_001","full_name":"Dr. Ramesh Babu Katta","specialty":"Cardiology",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","MD (Cardiology)","FACC"],"years_experience":18,"rating":4.9,"available":True,
   "consultation_fee_inr":1500},
  {"uid":"doc_apol_002","full_name":"Dr. Sunita Reddy","specialty":"Oncology",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","MD (Oncology)","FRCR"],"years_experience":14,"rating":4.8,"available":True,
   "consultation_fee_inr":2000},
  {"uid":"doc_apol_003","full_name":"Dr. Anil Kumar Sharma","specialty":"Neurology",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","DM (Neurology)"],"years_experience":12,"rating":4.7,"available":True,
   "consultation_fee_inr":1800},
  {"uid":"doc_apol_004","full_name":"Dr. Priyanka Venkatesh","specialty":"Infectious Disease",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","MD (Infectious Disease)"],"years_experience":10,"rating":4.8,"available":True,
   "consultation_fee_inr":1200},
  {"uid":"doc_apol_005","full_name":"Dr. Subrahmanyam Raju","specialty":"Neurosurgery",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","MS (Neurosurgery)","MCh"],"years_experience":20,"rating":4.9,"available":True,
   "consultation_fee_inr":2500},
  {"uid":"doc_apol_006","full_name":"Dr. Meena Lakshmi","specialty":"Psychiatry",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","MD (Psychiatry)"],"years_experience":8,"rating":4.7,"available":True,
   "consultation_fee_inr":1000},
  {"uid":"doc_apol_007","full_name":"Dr. Ravi Teja Nair","specialty":"Emergency Medicine",
   "hospital_id":"h001","hospital_name":"Apollo Hospitals, Jubilee Hills",
   "qualifications":["MBBS","MRCEM"],"years_experience":9,"rating":4.6,"available":True,
   "consultation_fee_inr":800},

  # ── KIMS Begumpet (h002) ───────────────────────────────────────────────────
  {"uid":"doc_kims_001","full_name":"Dr. Latha Prasad","specialty":"Pulmonology",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","MD (Respiratory Medicine)"],"years_experience":13,"rating":4.8,"available":True,
   "consultation_fee_inr":1200},
  {"uid":"doc_kims_002","full_name":"Dr. Srikanth Naidu","specialty":"Gastroenterology",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","DM (Gastroenterology)"],"years_experience":11,"rating":4.7,"available":True,
   "consultation_fee_inr":1500},
  {"uid":"doc_kims_003","full_name":"Dr. Kavitha Rao","specialty":"Dermatology",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","MD (Dermatology)","DVD"],"years_experience":9,"rating":4.8,"available":True,
   "consultation_fee_inr":900},
  {"uid":"doc_kims_004","full_name":"Dr. Venkateswara Rao Alla","specialty":"Orthopaedics",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","MS (Orthopaedics)","DNB"],"years_experience":16,"rating":4.9,"available":True,
   "consultation_fee_inr":1400},
  {"uid":"doc_kims_005","full_name":"Dr. Padmaja Srinivas","specialty":"Gynaecology",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","MS (OBG)","FMAS"],"years_experience":15,"rating":4.9,"available":True,
   "consultation_fee_inr":1300},
  {"uid":"doc_kims_006","full_name":"Dr. Nagendra Babu","specialty":"ENT",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","MS (ENT)"],"years_experience":10,"rating":4.6,"available":True,
   "consultation_fee_inr":800},
  {"uid":"doc_kims_007","full_name":"Dr. Rajani Kumari","specialty":"Nephrology",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","DM (Nephrology)"],"years_experience":12,"rating":4.7,"available":True,
   "consultation_fee_inr":1600},
  {"uid":"doc_kims_008","full_name":"Dr. Prasad Mukherjee","specialty":"General Surgery",
   "hospital_id":"h002","hospital_name":"KIMS-Sunshine Hospitals, Begumpet",
   "qualifications":["MBBS","MS (General Surgery)"],"years_experience":14,"rating":4.7,"available":True,
   "consultation_fee_inr":1200},

  # ── Continental Gachibowli (h003) ──────────────────────────────────────────
  {"uid":"doc_cont_001","full_name":"Dr. Aruna Mehta","specialty":"Endocrinology",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MD (Endocrinology)"],"years_experience":11,"rating":4.8,"available":True,
   "consultation_fee_inr":1400},
  {"uid":"doc_cont_002","full_name":"Dr. Vivek Chandra","specialty":"Ophthalmology",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MS (Ophthalmology)","FICO"],"years_experience":13,"rating":4.8,"available":True,
   "consultation_fee_inr":1000},
  {"uid":"doc_cont_003","full_name":"Dr. Radhika Potti","specialty":"Obstetrics",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MS (OBG)","FMAS","FICOG"],"years_experience":17,"rating":4.9,"available":True,
   "consultation_fee_inr":1800},
  {"uid":"doc_cont_004","full_name":"Dr. Sridhar Babu Kondeti","specialty":"Paediatrics",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MD (Paediatrics)","DCH"],"years_experience":14,"rating":4.8,"available":True,
   "consultation_fee_inr":1000},
  {"uid":"doc_cont_005","full_name":"Dr. Usha Kiranmayi","specialty":"Haematology",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MD (Haematology)"],"years_experience":10,"rating":4.7,"available":True,
   "consultation_fee_inr":1600},
  {"uid":"doc_cont_006","full_name":"Dr. Prashanth Reddy Nanduri","specialty":"ENT",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MS (ENT)","DOHNS"],"years_experience":8,"rating":4.6,"available":True,
   "consultation_fee_inr":900},
  {"uid":"doc_cont_007","full_name":"Dr. Sailaja Venugopal","specialty":"Paediatric Cardiology",
   "hospital_id":"h003","hospital_name":"Continental Hospitals, Gachibowli",
   "qualifications":["MBBS","MD (Paediatrics)","DM (Paediatric Cardiology)"],"years_experience":12,
   "rating":4.9,"available":True,"consultation_fee_inr":2000},
]

# ═══════════════════════════════════════════════════════════════════════════════
# 3.  ICD-10 PARTITIONING
# ═══════════════════════════════════════════════════════════════════════════════
all_codes = get_all()

# Chapter → hospital assignment
CHAPTER_MAP = {
    # Hospital 1: Apollo — complex/acute/neurological/oncology
    "I": "h001",  "II": "h001",  "V": "h001",
    "VI": "h001", "IX": "h001",  "XIX": "h001",
    # Hospital 2: KIMS — respiratory/digestive/skin/musculoskeletal/renal
    "X": "h002",  "XI": "h002",  "XII": "h002",
    "XIII": "h002","XIV": "h002",
    # Hospital 3: Continental — metabolic/eye/ear/maternal/paediatric
    "III": "h003","IV": "h003",  "VII": "h003",
    "VIII":"h003","XV": "h003",  "XVI": "h003", "XVII":"h003",
    # Test set: symptom codes + special + shared edge cases
    "XVIII":"test","XXI":"test",
}

splits = {"h001": [], "h002": [], "h003": [], "test": []}

# Primary assignment by chapter
for entry in all_codes:
    dest = CHAPTER_MAP.get(entry["chapter"], "test")
    splits[dest].append(entry)

# Add a 20% random sample from each hospital split into test set as well
# (so test set has cross-hospital coverage)
for hosp_id in ["h001","h002","h003"]:
    sample_size = max(1, len(splits[hosp_id]) // 5)
    test_sample = random.sample(splits[hosp_id], sample_size)
    for item in test_sample:
        t = dict(item)
        t["source_hospital"] = hosp_id
        splits["test"].append(t)

# ── Print summary ──────────────────────────────────────────────────────────
print("\n📊 ICD-10 Partition Summary")
print("─" * 55)
for key, label in [("h001","Apollo Jubilee Hills"),
                    ("h002","KIMS Begumpet"),
                    ("h003","Continental Gachibowli"),
                    ("test","Test / QA Set")]:
    specs = sorted(set(e["specialty"] for e in splits[key]))
    print(f"\n  {label} ({key}): {len(splits[key])} codes")
    print(f"  Chapters: {sorted(set(e['chapter'] for e in splits[key]))}")
    print(f"  Specialties: {specs}")

# ── Save JSON files ────────────────────────────────────────────────────────
for key, data in splits.items():
    fname = OUT / f"icd10_{key}.json"
    with open(fname, "w") as f:
        json.dump(data, f, indent=2)
    print(f"\n  ✅ Saved {fname}  ({len(data)} entries)")

# ── Save hospitals & doctors seed ─────────────────────────────────────────
with open(OUT / "hospitals_seed.json", "w") as f:
    json.dump(HOSPITALS, f, indent=2)
print(f"\n  ✅ Saved output/hospitals_seed.json  ({len(HOSPITALS)} hospitals)")

with open(OUT / "doctors_seed.json", "w") as f:
    json.dump(DOCTORS, f, indent=2)
print(f"\n  ✅ Saved output/doctors_seed.json  ({len(DOCTORS)} doctors)")

print(f"\n✅ Total ICD-10 codes: {len(all_codes)}")
print("   (Test set is larger because it includes 20% cross-hospital samples)")
