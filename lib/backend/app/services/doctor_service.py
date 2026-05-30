from fastapi import APIRouter, Query
from typing import List

router = APIRouter()

# Sample in-memory data; replace with real DB queries
DOCTORS = [
    {
        "id": "doc1",
        "name": "Dr. Alice",
        "hospital_id": "hosp1",
        "specialization": "Cardiology",
        "available_slots": ["2023-10-01T09:00:00", "2023-10-01T10:00:00"],
    },
    {
        "id": "doc2",
        "name": "Dr. Bob",
        "hospital_id": "hosp2",
        "specialization": "Dermatology",
        "available_slots": ["2023-10-02T11:00:00"],
    },
    # Add the remaining 20+ doctors here or fetch from Firestore
]

@router.get("/doctors", response_model=List[dict])
async def get_doctors(
    hospital_id: str = Query(..., description="Hospital identifier"),
    specialization: str = Query(..., description="Doctor specialization"),
):
    # Filter doctors by hospital and specialization
    filtered = [d for d in DOCTORS if d["hospital_id"] == hospital_id and d["specialization"].lower() == specialization.lower()]
    return filtered
