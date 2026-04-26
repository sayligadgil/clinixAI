# CliniX AI — Backend API

FastAPI · Firebase · XGBoost · Scikit-learn · Razorpay

---

## WHO ICD-10 Database

The WHO provides free access to ICD-10 classification data:

- **Browser**: https://icd.who.int/browse10/2019/en
- **Download**: https://www.who.int/standards/classifications/classification-of-diseases
- **API** (ICD-11 with ICD-10 bridge): https://icd.who.int/icdapi
  - Register at https://icd.who.int/icdapi → get a free client ID/secret
  - Endpoint: `https://id.who.int/icd/release/10/2019/{code}`

The backend already embeds the most common ICD-10 codes in `app/ml/symptom_classifier.py`
inside `ICD10_MAP`. For full ICD-10 lookup, call the WHO API at runtime.

---

## Project Structure

```
clinix-backend/
├── main.py                          # FastAPI app entry point
├── requirements.txt
├── Dockerfile
├── .env.example                     # Copy to .env and fill in keys
├── firestore.rules                  # Firestore security rules
├── seed_data.py                     # Populate Firestore with sample data
│
├── firebase_config/
│   └── serviceAccountKey.json       # ← Place your Firebase service account here
│
├── ml_models/
│   └── trained/                     # Auto-created on first run
│       ├── symptom_classifier.joblib
│       ├── label_encoder.joblib
│       └── anomaly_detector.joblib
│
├── app/
│   ├── config.py                    # Pydantic settings from .env
│   ├── firebase.py                  # Firebase Admin SDK helpers
│   │
│   ├── models/
│   │   └── schemas.py               # All Pydantic request/response models
│   │
│   ├── ml/
│   │   ├── symptom_classifier.py    # RandomForest disease classifier
│   │   ├── anomaly_detector.py      # IsolationForest anomaly detection
│   │   ├── doctor_matcher.py        # Cosine similarity doctor matching
│   │   └── prescription_generator.py # LLM + rule-based prescription
│   │
│   ├── services/
│   │   ├── ai_service.py            # Full AI pipeline orchestrator
│   │   └── payment_service.py       # Razorpay order + verification
│   │
│   ├── routers/
│   │   ├── auth.py                  # POST /auth/login, /register
│   │   ├── patient.py               # All patient endpoints
│   │   ├── doctor.py                # All doctor endpoints
│   │   ├── hospitals.py             # Hospital listing
│   │   └── admin.py                 # Admin stats + model retrain
│   │
│   └── utils/
│       ├── auth.py                  # JWT + Firebase token verification
│       └── pdf_generator.py         # ReportLab PDF prescription generator
│
└── tests/
    └── test_ml.py                   # Pytest unit tests (no Firebase needed)
```

---

## Setup

### 1. Firebase Project

1. Go to https://console.firebase.google.com → Create project → **clinix-ai**
2. Enable **Firestore** (Native mode)
3. Enable **Authentication** (Email/Password + Google)
4. Enable **Cloud Messaging** (for push notifications)
5. Go to **Project Settings → Service Accounts → Generate new private key**
6. Save as `firebase_config/serviceAccountKey.json`
7. Copy Firestore rules: **Firestore → Rules** → paste contents of `firestore.rules`

### 2. Environment Variables

```bash
cp .env.example .env
# Fill in all values in .env
```

### 3. Install & Run

```bash
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Seed Firestore with hospitals and doctors
python seed_data.py

# Start the API
uvicorn main:app --reload --port 8000
```

Open http://localhost:8000/docs for the interactive Swagger UI.

### 4. Run Tests (no Firebase needed)

```bash
pytest tests/ -v
```

---

## API Endpoints

### Auth
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/login` | Firebase ID token → JWT |
| POST | `/auth/register/patient` | Create patient profile |
| POST | `/auth/register/doctor` | Create doctor profile |

### Patient Flow
| Method | Path | Description |
|--------|------|-------------|
| GET | `/patient/profile/{uid}` | Get patient profile |
| PUT | `/patient/profile/{uid}` | Update patient profile |
| **POST** | **`/patient/intake`** | **Submit symptoms → AI analysis** |
| GET | `/patient/consultation/{id}` | Get consultation result |
| GET | `/patient/consultations/{uid}` | List all consultations |
| POST | `/patient/payment/order` | Create Razorpay order |
| **POST** | **`/patient/payment/verify`** | **Verify payment → generate prescription** |
| GET | `/patient/prescription/{id}` | Get prescription JSON |
| **GET** | **`/patient/prescription/{id}/pdf`** | **Download prescription PDF** |
| POST | `/patient/appointment` | Book appointment |
| GET | `/patient/appointments/{uid}` | List appointments |
| GET | `/patient/hospitals` | List hospitals |

### Doctor Flow
| Method | Path | Description |
|--------|------|-------------|
| GET | `/doctor/alerts/{uid}` | Pending patient alerts |
| POST | `/doctor/alert/{id}/resolve` | Resolve an alert |
| GET | `/doctor/consultations/{uid}` | All routed consultations |
| GET | `/doctor/consultation/{id}` | Full consultation detail |
| **POST** | **`/doctor/consultation/{id}/review`** | **Review / override AI diagnosis** |
| GET | `/doctor/appointments/{uid}` | Doctor's schedule |
| PUT | `/doctor/appointment/{id}/status` | Update appointment status |
| POST | `/doctor/prescription/{id}/override` | Write custom prescription |
| GET | `/doctor/dashboard/{uid}` | Stats dashboard |

---

## AI Pipeline (how it works)

```
Patient submits symptoms
        │
        ▼
┌─────────────────────┐
│ Symptom Classifier  │  RandomForest on 22 symptom features
│ (XGBoost ready)     │  → predicted_illness + confidence_score
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Anomaly Detector    │  IsolationForest
│                     │  → is_anomaly flag
└─────────┬───────────┘
          │
    confidence < 0.40?    ──YES──► Doctor Alert (FCM push)
    severity >= 9?                  Consultation status = "alerted"
    is_anomaly?                     Doctor reviews → approves prescription
          │
          NO
          ▼
┌─────────────────────┐
│ Doctor Matcher      │  Cosine similarity (SentenceTransformer)
│                     │  → best available specialist in patient's hospital
└─────────┬───────────┘
          │
          ▼ (after payment verified)
┌─────────────────────┐
│ Prescription Gen    │  1. OpenAI GPT-4o (if key set)
│                     │  2. Gemini 1.5 Pro (if key set)
│                     │  3. Rule-based KB (always available)
└─────────┬───────────┘
          │
          ▼
   Firestore saved → FCM to patient → PDF available
```

---

## Confidence Threshold Logic

| Condition | Action |
|-----------|--------|
| confidence ≥ 0.40 AND severity < 9 | Auto-generate prescription after payment |
| confidence < 0.40 | Alert doctor via FCM; doctor must review before prescription released |
| Anomaly detected | Alert doctor regardless of confidence |
| Severity = 9–10 | Emergency flag; doctor alerted; emergency warning in prescription |

---

## Deployment (Google Cloud Run)

```bash
# Build and push
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/clinix-backend

# Deploy
gcloud run deploy clinix-backend \
  --image gcr.io/YOUR_PROJECT_ID/clinix-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --set-env-vars FIREBASE_PROJECT_ID=your-project,LLM_PROVIDER=openai \
  --set-secrets OPENAI_API_KEY=openai-key:latest,RAZORPAY_KEY_SECRET=rzp-secret:latest
```

---

## Flutter Integration

In your Flutter app, point the `dio` base URL to your Cloud Run URL:

```dart
// lib/core/network/api_client.dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://clinix-backend-xxxx-uc.a.run.app',
  headers: {'Authorization': 'Bearer $jwtToken'},
));

// After Firebase sign-in:
final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
final response = await dio.post('/auth/login',
  data: {'id_token': idToken, 'role': 'patient'});
final jwt = response.data['access_token'];  // store securely
```
