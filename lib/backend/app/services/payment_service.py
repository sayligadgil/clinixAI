import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

def create_order(consultation_id: str, patient_uid: str, amount_paise: int, currency: str = "INR") -> Dict[str, Any]:
    """
    Placeholder for Razorpay order creation.
    """
    logger.info(f"Creating mock payment order for {patient_uid}")
    return {
        "id": f"order_mock_{consultation_id[:8]}",
        "entity": "order",
        "amount": amount_paise,
        "currency": currency,
        "status": "created"
    }

def verify_payment(order_id: str, payment_id: str, signature: str) -> bool:
    """
    Placeholder for Razorpay signature verification.
    For testing, this always returns True.
    """
    return True

def confirm_payment(order_id: str, payment_id: str) -> str:
    """
    Mock payment confirmation logic.
    """
    return f"pay_mock_{payment_id}"