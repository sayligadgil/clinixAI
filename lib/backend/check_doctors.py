import os
import sys

# Add the parent directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.firebase import get_firestore

db = get_firestore()
docs = db.collection('doctors').stream()
for doc in docs:
    print(f"ID: {doc.id}, Name: {doc.to_dict().get('full_name')}")
