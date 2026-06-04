# CliniX AI

CliniX AI is an intelligent, AI-powered telemedicine platform that bridges the gap between patients and healthcare professionals. The application facilitates remote consultations, automated symptom classification, anomaly detection, doctor matching, and AI-assisted prescription generation.

---

## Technology Stack

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Networking:** Dio (HTTP client for API requests)
- **UI Components:** Material Design, Cupertino Icons, Table Calendar

### Backend (FastAPI)
- **Framework:** FastAPI (Python)
- **Server:** Uvicorn
- **Data Validation:** Pydantic

### Machine Learning & AI
- **Symptom Classification:** RandomForest (via Scikit-learn), trained on 22 symptom features to predict illnesses and confidence scores.
- **Anomaly Detection:** IsolationForest (via Scikit-learn) to detect rare/unusual symptom combinations.
- **Doctor Matching:** Cosine Similarity using SentenceTransformers (`all-MiniLM-L6-v2`) to find the best available specialist based on symptoms.
- **Prescription Generation:** Integrated with GenAI (OpenAI GPT-4o / Gemini 1.5 Pro) with a rule-based fallback system. 

### Database & Authentication (Firebase)
- **Authentication:** Firebase Auth (Email/Password, Google)
- **Database:** Cloud Firestore (Native mode)
- **Notifications:** Firebase Cloud Messaging (FCM) for doctor alerts and patient notifications.

### Utilities & Integrations
- **Payments:** Razorpay integration for consultation fees.
- **PDF Generation:** ReportLab (Python) for creating downloadable prescription PDFs.
- **Medical Standards:** WHO ICD-10 Code lookup.

---

## AI Pipeline & Logic

```text
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
│ Prescription Gen    │  1. OpenAI GPT-4o / Gemini 1.5 Pro
│                     │  2. Rule-based KB (fallback)
└─────────┬───────────┘
          │
          ▼
   Firestore saved → FCM to patient → PDF available
```

### Confidence Threshold Logic
- **Confidence ≥ 0.40 & Severity < 9 & No Anomaly:** Auto-prescription (subject to business rules) after payment.
- **Confidence < 0.40 OR Anomaly Detected:** Flagged for mandatory doctor review via FCM.
- **Severity ≥ 9:** Emergency alert triggered immediately.

---

## Local Setup & Development

### 1. Firebase Setup
1. Go to https://console.firebase.google.com → Create project → **clinix-ai**
2. Enable **Firestore**, **Authentication**, and **Cloud Messaging**.
3. Generate a new private key: **Project Settings → Service Accounts**.
4. Save it as `lib/backend/firebase_config/serviceAccountKey.json`.
5. Deploy the `firestore.rules`.

### 2. Backend Setup
```bash
cd lib/backend
cp .env.example .env  # Fill in the keys (OpenAI, Razorpay, etc.)

python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Seed Firestore with hospitals and doctors
python seed_data.py

# Start the API
uvicorn main:app --reload --port 8000
```
Open `http://localhost:8000/docs` for the interactive Swagger UI.

### 3. Run Tests
```bash
pytest tests/ -v
```

---

## Dockerization & Google Cloud Hosting

### Dockerfile (Backend)
Place the following in `lib/backend/Dockerfile`:
```dockerfile
# Use official Python lightweight image
FROM python:3.10-slim
WORKDIR /app
RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

### Deploy to Google Cloud Run
```bash
cd lib/backend

# Submit the build to Google Cloud Build
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/clinix-backend

# Deploy to Cloud Run
gcloud run deploy clinix-backend \
  --image gcr.io/YOUR_PROJECT_ID/clinix-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars APP_ENV=production,FIREBASE_PROJECT_ID=clinixai-9fd9a \
  --set-secrets SECRET_KEY=clinix-secret:latest,OPENAI_API_KEY=openai-key:latest
```

### Flutter Integration
Point your Flutter app to the new Cloud Run URL:
```dart
final dio = Dio(BaseOptions(
  baseUrl: 'https://clinix-backend-xyz.a.run.app',
  // ...
));
```

---

## WHO ICD-10 Database
The backend embeds common ICD-10 codes in `app/ml/symptom_classifier.py`. For full ICD-10 lookup, call the WHO API at runtime (`https://icd.who.int/icdapi`).

## API Endpoints (Highlights)
- **Auth:** `POST /auth/login`, `POST /auth/register/patient`, `POST /auth/register/doctor`
- **Patient Flow:** `POST /patient/intake`, `POST /patient/payment/verify`, `GET /patient/prescription/{id}/pdf`, `POST /patient/appointment`
- **Doctor Flow:** `GET /doctor/alerts/{uid}`, `POST /doctor/consultation/{id}/review`, `GET /doctor/appointments/{uid}`, `PUT /doctor/appointment/{id}/status`
