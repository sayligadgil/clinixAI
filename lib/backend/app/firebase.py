import firebase_admin
from firebase_admin import credentials, firestore, auth, messaging
from typing import Optional, Dict, List, Any
from datetime import datetime
from .config import get_settings

settings = get_settings()

# 🔹 ADD THIS FUNCTION HERE
def init_firebase():
    """Initialize Firebase Admin SDK if not already initialized"""
    if not firebase_admin._apps:
        try:
            cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred, {
                'projectId': settings.PROJECT_ID
            })
            print("[OK] Firebase Initialized Successfully")
        except Exception as e:
            print(f"[ERROR] Failed to initialize Firebase: {e}")
            raise e

# Initialize database reference lazily - init_firebase() is called explicitly
# from the lifespan in main.py before any DB access happens.
_db = None

def get_db():
    """Return the Firestore client, initializing Firebase first if needed."""
    global _db
    if _db is None:
        init_firebase()
        _db = firestore.client()
    return _db

class FirebaseHelper:
    """Helper class for Firebase operations"""
    # ... rest of your code remains exactly the same ...

    @staticmethod
    def get_collection(collection_name: str):
        """Get a Firestore collection reference"""
        return get_db().collection(collection_name)

    @staticmethod
    def get_document(collection: str, doc_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve a single document"""
        doc = get_db().collection(collection).document(doc_id).get()
        if doc.exists:
            return {"id": doc.id, **doc.to_dict()}
        return None

    @staticmethod
    def create_document(collection: str, doc_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        """Create a new document"""
        data['created_at'] = firestore.SERVER_TIMESTAMP
        get_db().collection(collection).document(doc_id).set(data)
        return {"id": doc_id, **data}

    @staticmethod
    def update_document(collection: str, doc_id: str, data: Dict[str, Any]) -> bool:
        """Update an existing document"""
        data['updated_at'] = firestore.SERVER_TIMESTAMP
        get_db().collection(collection).document(doc_id).update(data)
        return True

    @staticmethod
    def query_documents(
        collection: str,
        filters: List[tuple],
        order_by: Optional[str] = None,
        limit: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        """Query documents with filters, optional ordering and limit."""
        query = get_db().collection(collection)
        for field, operator, value in filters:
            query = query.where(field, operator, value)
        if order_by:
            query = query.order_by(order_by)
        if limit:
            query = query.limit(limit)
        docs = query.stream()
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]

    @staticmethod
    def get_subcollection_docs(parent_collection: str, parent_id: str,
                                subcollection: str) -> List[Dict[str, Any]]:
        """Get all documents from a subcollection"""
        docs = get_db().collection(parent_collection).document(parent_id)\
                 .collection(subcollection).stream()
        return [{"id": doc.id, **doc.to_dict()} for doc in docs]

    @staticmethod
    def create_user(email: str, password: str, display_name: str) -> str:
        """Create a Firebase Auth user"""
        user = auth.create_user(
            email=email,
            password=password,
            display_name=display_name
        )
        return user.uid

    @staticmethod
    def verify_token(id_token: str) -> Dict[str, Any]:
        """Verify Firebase ID token"""
        try:
            decoded_token = auth.verify_id_token(id_token)
            return decoded_token
        except Exception as e:
            raise ValueError(f"Invalid token: {str(e)}")

    @staticmethod
    def get_doctor_by_uid(uid: str) -> Optional[Dict[str, Any]]:
        """Get doctor by Firebase UID"""
        return FirebaseHelper.get_document("doctors", uid)

    @staticmethod
    def get_patient_by_uid(uid: str) -> Optional[Dict[str, Any]]:
        """Get patient by Firebase UID"""
        return FirebaseHelper.get_document("patients", uid)

    @staticmethod
    def get_doctors_by_hospital(hospital_id: str) -> List[Dict[str, Any]]:
        """Get all doctors from a specific hospital"""
        return FirebaseHelper.query_documents("doctors", [('hospital_id', '==', hospital_id)])

    @staticmethod
    def get_icd10_codes_for_hospital(hospital_id: str) -> List[Dict[str, Any]]:
        """Get ICD-10 codes assigned to a hospital"""
        return FirebaseHelper.get_subcollection_docs("hospitals", hospital_id, "icd10_codes")

    @staticmethod
    def create_consultation(data: Dict[str, Any]) -> str:
        """Create a new consultation"""
        doc_ref = get_db().collection("consultations").document()
        data['created_at'] = firestore.SERVER_TIMESTAMP
        data['status'] = 'pending'
        doc_ref.set(data)
        return doc_ref.id

    @staticmethod
    def create_alert(data: Dict[str, Any]) -> str:
        """Create a new alert for doctors"""
        doc_ref = get_db().collection("alerts").document()
        data['created_at'] = firestore.SERVER_TIMESTAMP
        data['status'] = 'unread'
        doc_ref.set(data)
        return doc_ref.id

    @staticmethod
    def get_alerts_for_hospital(hospital_id: str, status: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get alerts for a specific hospital"""
        filters = [('hospital_id', '==', hospital_id)]
        if status:
            filters.append(('status', '==', status))
        return FirebaseHelper.query_documents("alerts", filters)

    @staticmethod
    def send_push_notification(token: str, title: str, body: str, data: Optional[Dict[str, str]] = None):
        """Send a Firebase Cloud Messaging (FCM) push notification"""
        message = messaging.Message(
        notification=messaging.Notification(
        title=title,
        body=body,
        ),
        data=data or {},
        token=token,
        )
        try:
            response = messaging.send(message)
            return response
        except Exception as e:
            print(f"❌ FCM Error: {e}")
            return None


# ─── STANDALONE EXPORTS FOR ROUTERS ───
# Mapping all names expected by patient.py and other routers
get_doc = FirebaseHelper.get_document
set_doc = FirebaseHelper.create_document
query_collection = FirebaseHelper.query_documents
get_firestore = get_db  # provides the db instance

def add_doc(collection: str, data: Dict[str, Any]) -> str:
    """Generic: add a new auto-ID document to any collection. Returns the new doc ID."""
    doc_ref = get_db().collection(collection).document()
    data.setdefault('created_at', firestore.SERVER_TIMESTAMP)
    doc_ref.set(data)
    return doc_ref.id
# 🔹 Fix: COLLECTION must be a dictionary for the router to work
COLLECTION = {
    "patients": "patients",
    "doctors": "doctors",
    "hospitals": "hospitals",
    "consultations": "consultations",
    "appointments": "appointments",
    "prescriptions": "prescriptions",
    "alerts": "alerts"
}
send_push = FirebaseHelper.send_push_notification

# Export singleton instance
firebase_helper = FirebaseHelper()