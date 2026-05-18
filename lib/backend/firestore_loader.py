"""
firestore_loader.py
─────────────────────────────────────────────────────────────────────────────
Loads all generated seed data into Firestore.

Requires:
  • serviceAccountKey.json in ../firebase_config/ OR set GOOGLE_APPLICATION_CREDENTIALS
  • Run partition_and_seed.py first to generate output/ files

Usage:
  python3 firestore_loader.py [--dry-run]

Flags:
  --dry-run   : Print what would be uploaded without touching Firestore
  --hospitals : Upload hospitals only
  --doctors   : Upload doctors only
  --icd10     : Upload ICD-10 splits only
  --all       : Upload everything (default)
"""
import json
import sys
import os
import argparse
from pathlib import Path
from datetime import datetime, timezone

# ── Arg parsing ──────────────────────────────────────────────────────────────
parser = argparse.ArgumentParser(description="Seed Firestore with CliniX data")
parser.add_argument("--dry-run",   action="store_true", help="Preview only, no writes")
parser.add_argument("--hospitals", action="store_true")
parser.add_argument("--doctors",   action="store_true")
parser.add_argument("--icd10",     action="store_true")
parser.add_argument("--project",   default=os.getenv("clinixai-9fd9a","clinixai"))
parser.add_argument("--sa-path",   default="firebase_config/serviceAccountKey.json")
args = parser.parse_args()

# If none specified, do all
do_all = not (args.hospitals or args.doctors or args.icd10)

OUT = Path("output")
DRY = args.dry_run
NOW = datetime.now(timezone.utc).isoformat()

# ── Firebase init ─────────────────────────────────────────────────────────────
if not DRY:
    import firebase_admin
    from firebase_admin import credentials, firestore

    sa_path = Path(args.sa_path)
    if sa_path.exists():
        cred = credentials.Certificate(str(sa_path))
        print(f"🔑 Using service account: {sa_path}")
    else:
        cred = credentials.ApplicationDefault()
        print("🔑 Using Application Default Credentials")

    firebase_admin.initialize_app(cred, {"projectId": args.project})
    db = firestore.client()
    print(f"✅ Connected to Firestore project: {args.project}\n")
else:
    db = None
    print("🔍 DRY RUN mode — no writes to Firestore\n")


def write(collection: str, doc_id: str, data: dict):
    if DRY:
        print(f"  [DRY] {collection}/{doc_id}: {list(data.keys())}")
    else:
        db.collection(collection).document(doc_id).set(data, merge=True)


def load_json(path: Path) -> list:
    with open(path) as f:
        return json.load(f)


# ═══════════════════════════════════════════════════════════════════════════════
# A. HOSPITALS
# ═══════════════════════════════════════════════════════════════════════════════
if do_all or args.hospitals:
    hospitals = load_json(OUT / "hospitals_seed.json")
    print(f"🏥 Uploading {len(hospitals)} hospitals...")
    for h in hospitals:
        h["created_at"] = NOW
        h["updated_at"] = NOW
        write("hospitals", h["id"], h)
        print(f"   ✅ {h['name']} ({h['id']})")
    print()

# ═══════════════════════════════════════════════════════════════════════════════
# B. DOCTORS
# ═══════════════════════════════════════════════════════════════════════════════
if do_all or args.doctors:
    doctors = load_json(OUT / "doctors_seed.json")
    print(f"👨‍⚕️  Uploading {len(doctors)} doctors...")
    for d in doctors:
        d["created_at"] = NOW
        d["updated_at"] = NOW
        d["fcm_token"]  = None   # populated when doctor logs into app
        write("doctors", d["uid"], d)
        print(f"   ✅ {d['full_name']} → {d['hospital_name']} ({d['specialty']})")
    print()

# ═══════════════════════════════════════════════════════════════════════════════
# C. ICD-10 CODES  (stored per-hospital in a sub-collection for fast queries)
# ═══════════════════════════════════════════════════════════════════════════════
if do_all or args.icd10:
    splits = {
        "h001": "icd10_h001.json",
        "h002": "icd10_h002.json",
        "h003": "icd10_h003.json",
        "test": "icd10_test.json",
    }

    for split_key, filename in splits.items():
        codes = load_json(OUT / filename)
        label = "TEST SET" if split_key == "test" else split_key
        print(f"📋 Uploading ICD-10 split [{label}] — {len(codes)} codes...")

        if split_key == "test":
            # Test codes go into a dedicated collection for ML validation
            for code_entry in codes:
                cid = code_entry["code"].replace(".","_")
                code_entry["split"] = "test"
                code_entry["created_at"] = NOW
                write("icd10_test", cid, code_entry)
        else:
            # Hospital codes go into hospital/{id}/icd10_codes sub-collection
            # AND into a flat icd10_codes collection with hospital_id field
            for code_entry in codes:
                cid = code_entry["code"].replace(".","_")
                code_entry["hospital_id"] = split_key
                code_entry["split"] = split_key
                code_entry["created_at"] = NOW

                # Flat collection (easier to query across hospitals)
                write("icd10_codes", f"{split_key}_{cid}", code_entry)

                # Sub-collection (for hospital-scoped queries)
                if not DRY:
                    db.collection("hospitals").document(split_key)\
                      .collection("icd10_codes").document(cid).set(code_entry, merge=True)
                else:
                    print(f"  [DRY] hospitals/{split_key}/icd10_codes/{cid}")

        print(f"   ✅ {len(codes)} codes written\n")

# ═══════════════════════════════════════════════════════════════════════════════
# D. SAMPLE PATIENTS (for testing the full AI pipeline)
# ═══════════════════════════════════════════════════════════════════════════════
if do_all and not DRY:
    print("👤 Creating sample patient accounts...")
    sample_patients = [
        {"uid":"patient_test_001","full_name":"Arjun Reddy","age":28,"sex":"Male",
         "weight_kg":72,"blood_type":"O+","known_allergies":[],"chronic_conditions":[],
         "preferred_hospital":"h001"},
        {"uid":"patient_test_002","full_name":"Priya Lakshmi","age":35,"sex":"Female",
         "weight_kg":58,"blood_type":"A+","known_allergies":["Penicillin"],
         "chronic_conditions":["Type 2 Diabetes"],"preferred_hospital":"h002"},
        {"uid":"patient_test_003","full_name":"Venkat Rao","age":52,"sex":"Male",
         "weight_kg":85,"blood_type":"B+","known_allergies":[],"chronic_conditions":["Hypertension"],
         "preferred_hospital":"h001"},
        {"uid":"patient_test_004","full_name":"Nandini Sharma","age":24,"sex":"Female",
         "weight_kg":55,"blood_type":"AB+","known_allergies":[],"chronic_conditions":[],
         "preferred_hospital":"h003"},
    ]
    for p in sample_patients:
        p["created_at"] = NOW
        p["fcm_token"] = None
        write("patients", p["uid"], p)
        print(f"   ✅ {p['full_name']} ({p['uid']})")
    print()

# ── Summary ──────────────────────────────────────────────────────────────────
print("\n" + "═"*55)
print("✅ SEED COMPLETE" if not DRY else "🔍 DRY RUN COMPLETE (nothing written)")
print("═"*55)
print("\nFirestore collections populated:")
print("  • hospitals          (3 documents)")
print("  • doctors            (22 documents)")
print("  • icd10_codes        (235 documents, partitioned by hospital)")
print("  • icd10_test         (59 documents, cross-hospital test set)")
print("  • patients           (4 sample accounts)")
print("\nSub-collections:")
print("  • hospitals/h001/icd10_codes   (110 codes — Apollo)")
print("  • hospitals/h002/icd10_codes   (74 codes  — KIMS)")
print("  • hospitals/h003/icd10_codes   (51 codes  — Continental)")
if DRY:
    print("\n👉  Remove --dry-run flag to write to Firestore.")
