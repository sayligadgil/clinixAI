from fastapi import APIRouter, HTTPException
from typing import List, Optional
from ..firebase import query_collection, COLLECTION

router = APIRouter(prefix="/hospitals", tags=["Hospitals"])

@router.get("/")
async def get_hospitals(city: Optional[str] = None):
    """
    Fetch the list of partner hospitals from Firestore.
    """
    try:
        filters = []
        if city:
            filters.append(("city", "==", city))

        # Using the helper we fixed earlier
        hospitals = query_collection(COLLECTION["hospitals"], filters=filters)
        return hospitals
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch hospitals: {str(e)}")

@router.get("/{hospital_id}")
async def get_hospital_details(hospital_id: str):
    """
    Get detailed information about a specific hospital.
    """
    from ..firebase import get_doc
    doc = get_doc(COLLECTION["hospitals"], hospital_id)
    if not doc:
        raise HTTPException(status_code=404, detail="Hospital not found")
    return doc