import os
import sys
from firebase_admin import auth

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.firebase import get_firestore

db = get_firestore()
print('--- AUTH USERS ---')
try:
    for user in auth.list_users().iterate_all():
        print(f"UID: {user.uid}, Email: {user.email}")
except Exception as e:
    print(f"Failed to list auth users: {e}")

print('--- DOCTORS ---')
for doc in db.collection('doctors').stream():
    print(f"ID: {doc.id}, Name: {doc.to_dict().get('full_name')}")
