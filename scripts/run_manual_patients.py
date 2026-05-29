import requests, random, json, os

# Configuration
API_BASE = 'http://localhost:8000'  # Adjust if backend runs elsewhere
ENDPOINT = f"{API_BASE}/patient/intake"
TOKEN = os.getenv('CLINIXAI_TOKEN')  # Set auth token if needed

# List of symptoms from frontend default list
SYMPTOMS = [
    'Fever', 'Dry Cough', 'Fatigue', 'Headache', 'Sore Throat',
    'Nausea', 'Vomiting', 'Chest Pain', 'Shortness of Breath', 'Abdominal Pain',
    'Cough', 'Pain', 'Abnormal Heartbeat', 'Respiratory Hemorrhage',
    'Abnormal Breathing', 'Throat and Chest Pain', 'Abdominal and Pelvic Pain',
    'Nausea and Vomiting', 'Syncope', 'Elevated Blood Glucose'
]

# Sample patient names
NAMES = [
    'Amit Sharma', 'Neha Patel', 'Rohit Kumar', 'Sanjana Rao', 'Vikram Singh',
    'Priya Desai', 'Karan Mehta', 'Ananya Gupta', 'Arjun Nair', 'Sneha Joshi'
]

def random_symptom_set():
    # Choose 2-5 random symptoms
    count = random.randint(2, 5)
    chosen = random.sample(SYMPTOMS, count)
    return [{'name': s, 'severity': random.randint(5, 10), 'duration_days': 1} for s in chosen]

for i in range(10):
    data = {
        'patient_uid': f'test_user_{i}',
        'full_name': NAMES[i % len(NAMES)],
        'age': random.randint(20, 65),
        'hospital_id': 'apollo_jh',  # Use first hospital from frontend list
        'symptoms': random_symptom_set(),
        'description': 'Synthetic intake for testing purposes.'
    }
    headers = {'Content-Type': 'application/json'}
    if TOKEN:
        headers['Authorization'] = f'Bearer {TOKEN}'
    try:
        resp = requests.post(ENDPOINT, json=data, headers=headers)
        print(f'Patient {i+1}: status {resp.status_code}')
        if resp.status_code == 200:
            print(json.dumps(resp.json(), indent=2))
        else:
            print('Error response:', resp.text)
    except Exception as e:
        print('Request failed:', e)
        break
