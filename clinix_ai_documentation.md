# CliniX AI - Comprehensive Project Documentation

## 1. Overview
CliniX AI is an intelligent, AI-powered telemedicine platform that bridges the gap between patients and healthcare professionals. The application facilitates remote consultations, automated symptom classification, anomaly detection, doctor matching, and AI-assisted prescription generation.

## 2. Technology Stack

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Networking:** Dio (HTTP client for API requests)
- **UI Components:** Material Design, Cupertino Icons, Table Calendar

### Backend
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

## 3. Application Architecture & Working

### Patient Flow
1. **Intake & Triage:** Patients submit their symptoms via the Flutter app.
2. **AI Analysis:** The backend processes symptoms using the ML pipeline.
3. **Doctor Matching:** A suitable specialist within the selected hospital is identified.
4. **Payment:** Patient completes payment (Razorpay).
5. **Prescription:** Upon payment verification, if the AI confidence is high and no anomalies/critical severities are detected, an auto-prescription may be generated. Otherwise, it routes to a doctor for review.
6. **Appointments:** Patients can view available slots and book follow-up or standard appointments with doctors.

### Doctor Flow
1. **Dashboard:** Doctors view alerts, schedules, and pending consultations.
2. **Review:** For low-confidence or high-severity cases, doctors receive an FCM alert.
3. **Approval:** The doctor reviews the AI's diagnosis, overrides it if necessary, and approves the prescription.
4. **Resolution:** The final prescription is sent back to the patient.
5. **Appointments:** Doctors manage their daily schedule, view upcoming patient appointments, and update appointment statuses.

### AI Pipeline Logic
- **Confidence ≥ 0.70 & Severity < 0.8 & Anomaly Score < 0.7:** Auto-prescription (subject to business rules).
- **Confidence < 0.70 OR Anomaly Score ≥ 0.7:** Flagged for mandatory doctor review.
- **Severity ≥ 0.8:** Emergency high-risk alert triggered immediately.

---

## 4. Prompt Template for AI Context (Copy & Paste)
*Use this text when starting a new chat with an LLM to provide context about the project:*

> "I am working on a project named 'CliniX AI'. It is a telemedicine platform. 
> **Frontend:** Flutter (Dart), Provider for state management, Dio for networking. 
> **Backend:** Python FastAPI, Pydantic, Uvicorn.
> **Database & Auth:** Firebase Firestore, Firebase Auth, FCM for push notifications. 
> **ML Pipeline:** Scikit-learn RandomForest (Symptom Classifier), IsolationForest (Anomaly Detector), SentenceTransformers (Doctor Matcher), LLM integration (GPT-4o/Gemini) for prescription generation. ReportLab for PDF generation.
> **Flow:** Patients submit symptoms -> FastAPI backend runs ML models -> if high confidence/low severity, auto-generate prescription (after Razorpay payment) -> else, alert doctor via FCM for manual review. 
> Please keep this stack and flow in mind for all subsequent requests."

---

## 5. Dockerization Guide

Since the backend is built with FastAPI, you will need a `Dockerfile` to containerize the application. 

### Recommended `Dockerfile` (Place in `lib/backend/Dockerfile`):
```dockerfile
# Use official Python lightweight image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire backend source code
COPY . .

# Expose port (Cloud Run defaults to 8080)
EXPOSE 8080

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

---

## 6. Google Cloud Hosting Guide

### Step 1: Push to Google Artifact Registry / Container Registry
First, ensure you have the `gcloud` CLI installed and authenticated (`gcloud auth login`).

```bash
# Navigate to the backend directory
cd lib/backend

# Submit the build to Google Cloud Build
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/clinix-backend
```

### Step 2: Deploy to Google Cloud Run
Deploy the built container to Cloud Run. This provides automatic scaling and HTTPS out-of-the-box.

```bash
gcloud run deploy clinix-backend \
  --image gcr.io/YOUR_PROJECT_ID/clinix-backend \
  --platform managed \
  --region asia-south1 \
  --allow-unauthenticated \
  --port 8080 \
  --set-env-vars APP_ENV=production,FIREBASE_PROJECT_ID=clinixai-9fd9a \
  --set-secrets SECRET_KEY=clinix-secret:latest,OPENAI_API_KEY=openai-key:latest
```

*(Note: Ensure you have set up Secret Manager in Google Cloud for your sensitive API keys).*

### Step 3: Frontend Integration
Once deployed, Google Cloud Run will provide a URL (e.g., `https://clinix-backend-xyz.a.run.app`). 
Update your Flutter app's Dio `baseUrl` to point to this new URL.

```dart
// In Flutter API Client setup
final dio = Dio(BaseOptions(
  baseUrl: 'https://clinix-backend-xyz.a.run.app',
  // ...
));
```
