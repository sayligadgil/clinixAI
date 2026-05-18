"""
verify_splits.py — Sanity-check all 4 splits are correct and non-overlapping.
Run: python3 verify_splits.py
"""
import json
from pathlib import Path
from collections import Counter

OUT = Path("output")

splits = {}
for key in ["h001","h002","h003","test"]:
    with open(OUT / f"icd10_{key}.json") as f:
        splits[key] = json.load(f)

print("\n" + "═"*60)
print("  ICD-10 SPLIT VERIFICATION REPORT")
print("═"*60)

hospital_names = {
    "h001": "Apollo Jubilee Hills",
    "h002": "KIMS Begumpet",
    "h003": "Continental Gachibowli",
    "test": "Test / QA Set",
}

all_primary_codes = set()
overlap_errors = []

for key, data in splits.items():
    codes = [e["code"] for e in data]
    chapters = sorted(set(e["chapter"] for e in data))
    specialties = sorted(set(e["specialty"] for e in data))
    chapter_counts = Counter(e["chapter"] for e in data)

    print(f"\n  [{key}] {hospital_names[key]}")
    print(f"  ├─ Total codes : {len(data)}")
    print(f"  ├─ Chapters    : {chapters}")
    print(f"  ├─ Specialties : {len(specialties)} unique")
    print(f"  └─ Breakdown   : " +
          ", ".join(f"Ch{c}={n}" for c,n in sorted(chapter_counts.items())))

    if key != "test":
        # Check no overlap between hospital splits (primary only)
        overlap = all_primary_codes & set(codes)
        if overlap:
            overlap_errors.append(f"  ❌ OVERLAP in {key}: {overlap}")
        all_primary_codes |= set(codes)

# Test set includes cross-hospital samples — overlaps are expected
print(f"\n  [test] includes {len([e for e in splits['test'] if 'source_hospital' in e])} "
      f"cross-hospital samples (intentional overlap)")

# Check total coverage
total_unique = len(all_primary_codes)
print(f"\n  Hospital splits cover {total_unique} unique primary codes")

if overlap_errors:
    print("\n  ⚠️  OVERLAP ERRORS:")
    for e in overlap_errors:
        print(e)
else:
    print("\n  ✅ No overlaps between hospital splits (h001/h002/h003)")

# WHO download links
print("\n" + "═"*60)
print("  WHERE TO GET THE FULL WHO ICD-10 DATABASE")
print("═"*60)
print("""
  1. Browse online (all 14,000+ codes):
     https://icd.who.int/browse10/2019/en

  2. Official WHO download page:
     https://www.who.int/standards/classifications/classification-of-diseases
     → Click "ICD-10 Version 2019" → request download

  3. WHO ICD API (programmatic, free registration):
     https://icd.who.int/icdapi
     Register → get client_id + client_secret → call:
     GET https://id.who.int/icd/release/10/2019/{code}

  4. CMS ICD-10-CM (US version, free CSV, 76,000+ codes):
     https://www.cms.gov/medicare/coding/icd10/2019-icd-10-cm
     → Download: 2019-ICD-10-CM-Code-Descriptions.zip

  5. GitHub ready-to-use CSV (sourced from CMS):
     https://github.com/Bobrovskiy/ICD-10-CSV

  To extend this project's ICD-10 list to all 76,000 codes,
  download the CMS CSV and replace icd10_full.py's ICD10_DATA
  with a pandas-loaded version of that CSV.
""")
