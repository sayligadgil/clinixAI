from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any
from ..firebase import firebase_helper, query_collection, COLLECTION
from ..models.schemas import SuccessResponse, RiskLevel
# Using relative import since auth.py is in the same directory
from .auth import get_current_user, CurrentUser

router = APIRouter(prefix="/admin", tags=["Admin"])

# ─── Dependency to restrict to Admin ───
def require_admin(user: CurrentUser = Depends(get_current_user)):
    if user.role != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return user

# ─── System Metrics ───
@router.get("/stats")
async def get_system_stats(admin: CurrentUser = Depends(require_admin)):
    """Overview of the entire CliniX AI ecosystem"""
    # This queries the counts from your collections
    patients = query_collection(COLLECTION["patients"], limit=1000)
    doctors = query_collection(COLLECTION["doctors"], limit=1000)
    consultations = query_collection(COLLECTION["consultations"], limit=1000)

    return {
        "total_patients": len(patients),
        "total_doctors": len(doctors),
        "total_consultations": len(consultations),
        "active_hospitals": 3  # Based on your validated hospital IDs
    }

# ─── High-Risk Alert Management ───
@router.get("/alerts/critical")
async def get_critical_alerts(admin: CurrentUser = Depends(require_admin)):
    """Monitor high-risk cases that require system-wide attention"""
    return query_collection(
        COLLECTION["alerts"],
        filters=[("severity", "==", RiskLevel.CRITICAL), ("is_resolved", "==", False)]
    )

# ─── Hospital Management ───
@router.post("/hospitals/add")
async def register_new_hospital(hospital_data: Dict[str, Any], admin: CurrentUser = Depends(require_admin)):
    """Onboard a new partner hospital to the network"""
    from ..firebase import set_doc
    h_id = hospital_data.get("hospital_id")
    if not h_id:
        raise HTTPException(status_code=400, detail="Hospital ID required")

    set_doc(COLLECTION["hospitals"], h_id, hospital_data)
    return SuccessResponse(message=f"Hospital {h_id} registered successfully")