import os
import sys
from firebase_admin import auth

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.firebase import get_firestore

db = get_firestore()
docs = db.collection('doctors').stream()
deleted_count = 0

for doc in docs:
    id_str = doc.id
    if not id_str.startswith('doc_'):
        print(f"Deleting duplicate doctor: {id_str}")
        db.collection('doctors').document(id_str).delete()
        # Also try to delete the auth user
        try:
            auth.delete_user(id_str)
            print(f"Deleted auth user {id_str}")
        except Exception as e:
            print(f"Auth user {id_str} not found or error: {e}")
        deleted_count += 1

print(f"Deleted {deleted_count} duplicate doctors.")
