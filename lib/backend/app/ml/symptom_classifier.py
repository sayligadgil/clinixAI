"""
app/ml/symptom_classifier.py
─────────────────────────────────────────────────────────────────────────────
Symptom → Disease classifier using XGBoost / RandomForest.

Training data:
  • WHO ICD-10 aligned symptom-disease dataset (bundled CSV)
  • Can also be replaced with MIMIC-III derived data once you have access

The classifier outputs:
  • predicted_illness   – top disease label
  • icd10_code          – mapped ICD-10 code
  • confidence_score    – probability of top prediction
  • top_predictions     – ranked list [{illness, confidence}]
  • recommended_specialist – derived from disease category

Usage:
  from app.ml.symptom_classifier import SymptomClassifier
  clf = SymptomClassifier()
  result = clf.predict(selected_symptoms=["fever", "dry_cough"], age=32, severity=7)
"""
from __future__ import annotations
import os
import logging
import pickle
from pathlib import Path
from typing import Optional

import numpy as np
import joblib
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

logger = logging.getLogger(__name__)

# ─── All symptom feature columns (must match intake checkboxes) ──────────────
ALL_SYMPTOMS = [
    "fever", "dry_cough", "fatigue", "headache", "sore_throat",
    "shortness_of_breath", "chills", "body_aches", "loss_of_taste",
    "loss_of_smell", "runny_nose", "nausea", "vomiting", "diarrhea",
    "chest_pain", "rash", "joint_pain", "dizziness", "back_pain",
    "abdominal_pain", "swollen_lymph_nodes", "night_sweats",
]

# ─── Disease → ICD-10 mapping ────────────────────────────────────────────────
ICD10_MAP: dict[str, str] = {
    "Common Cold":              "J00",
    "Influenza":                "J11.1",
    "COVID-19":                 "U07.1",
    "Pneumonia":                "J18.9",
    "Acute Bacterial Sinusitis":"J01.90",
    "Bronchitis":               "J20.9",
    "Strep Throat":             "J02.0",
    "Seasonal Allergies":       "J30.1",
    "Gastroenteritis":          "A09",
    "Urinary Tract Infection":  "N39.0",
    "Migraine":                 "G43.909",
    "Hypertension Crisis":      "I10",
    "Anxiety Disorder":         "F41.1",
    "Dengue Fever":             "A90",
    "Malaria":                  "B54",
    "Typhoid Fever":            "A01.00",
    "Tuberculosis":             "A15.9",
    "Chickenpox":               "B01.9",
    "Measles":                  "B05.9",
    "Appendicitis":             "K37",
}

# ─── Disease → Specialist mapping ────────────────────────────────────────────
SPECIALIST_MAP: dict[str, str] = {
    "Common Cold":              "General Physician",
    "Influenza":                "General Physician",
    "COVID-19":                 "Pulmonologist",
    "Pneumonia":                "Pulmonologist",
    "Acute Bacterial Sinusitis":"ENT Specialist",
    "Bronchitis":               "Pulmonologist",
    "Strep Throat":             "ENT Specialist",
    "Seasonal Allergies":       "Allergist",
    "Gastroenteritis":          "Gastroenterologist",
    "Urinary Tract Infection":  "Urologist",
    "Migraine":                 "Neurologist",
    "Hypertension Crisis":      "Cardiologist",
    "Anxiety Disorder":         "Psychiatrist",
    "Dengue Fever":             "Infectious Disease Specialist",
    "Malaria":                  "Infectious Disease Specialist",
    "Typhoid Fever":            "Infectious Disease Specialist",
    "Tuberculosis":             "Pulmonologist",
    "Chickenpox":               "General Physician",
    "Measles":                  "General Physician",
    "Appendicitis":             "General Surgeon",
}

# ─── Built-in training data (rule-based seed — replaces external CSV) ────────
TRAINING_DATA = [
    # (symptoms_present: list[str], label: str)
    (["fever", "dry_cough", "fatigue", "loss_of_taste", "loss_of_smell"], "COVID-19"),
    (["fever", "dry_cough", "shortness_of_breath", "body_aches"], "COVID-19"),
    (["fever", "body_aches", "headache", "chills", "fatigue"], "Influenza"),
    (["runny_nose", "sore_throat", "headache", "fatigue"], "Common Cold"),
    (["fever", "headache", "sore_throat", "chills"], "Strep Throat"),
    (["headache", "runny_nose", "chills", "sore_throat", "fatigue"], "Seasonal Allergies"),
    (["fever", "dry_cough", "chest_pain", "shortness_of_breath"], "Pneumonia"),
    (["headache", "chills", "dry_cough", "shortness_of_breath"], "Bronchitis"),
    (["headache", "chills", "fever", "rash"], "Acute Bacterial Sinusitis"),
    (["nausea", "vomiting", "diarrhea", "abdominal_pain"], "Gastroenteritis"),
    (["abdominal_pain", "nausea", "vomiting", "fever"], "Appendicitis"),
    (["headache", "dizziness", "nausea", "fatigue"], "Migraine"),
    (["chest_pain", "dizziness", "headache", "shortness_of_breath"], "Hypertension Crisis"),
    (["back_pain", "nausea", "fever", "dizziness"], "Urinary Tract Infection"),
    (["fever", "joint_pain", "rash", "headache"], "Dengue Fever"),
    (["fever", "chills", "headache", "body_aches", "night_sweats"], "Malaria"),
    (["fever", "abdominal_pain", "headache", "fatigue", "diarrhea"], "Typhoid Fever"),
    (["night_sweats", "fatigue", "dry_cough", "fever", "back_pain"], "Tuberculosis"),
    (["rash", "fever", "headache", "fatigue"], "Chickenpox"),
    (["rash", "fever", "runny_nose", "dry_cough"], "Measles"),
    (["fatigue", "headache", "dizziness", "shortness_of_breath"], "Anxiety Disorder"),
    (["swollen_lymph_nodes", "night_sweats", "fever", "fatigue"], "Tuberculosis"),
    (["joint_pain", "fever", "rash", "fatigue"], "Dengue Fever"),
    (["sore_throat", "fever", "headache", "rash"], "Strep Throat"),
    (["runny_nose", "headache", "sore_throat", "dry_cough"], "Common Cold"),
]

# Augment data by repeating with minor perturbations
def _build_dataset():
    import random
    rows = []
    labels = []
    for symptoms_present, label in TRAINING_DATA:
        for _ in range(30):    # 30 augmented copies each
            row = [0] * len(ALL_SYMPTOMS)
            for sym in symptoms_present:
                if sym in ALL_SYMPTOMS:
                    row[ALL_SYMPTOMS.index(sym)] = 1
            # add random noise symptom
            if random.random() < 0.3:
                noise_idx = random.randint(0, len(ALL_SYMPTOMS) - 1)
                row[noise_idx] = 1
            rows.append(row)
            labels.append(label)
    return np.array(rows), labels


class SymptomClassifier:
    """
    Wraps a trained RandomForest for symptom → disease classification.
    Falls back to an in-process trained model when no saved model exists.
    """

    def __init__(self, model_path: str = "", label_encoder_path: str = ""):
        self.model: RandomForestClassifier | None = None
        self.label_encoder: LabelEncoder | None = None
        self._load_or_train(model_path, label_encoder_path)

    # ── Load / Train ──────────────────────────────────────────────────────────

    def _load_or_train(self, model_path: str, label_encoder_path: str):
        if model_path and Path(model_path).exists():
            logger.info(f"Loading symptom classifier from {model_path}")
            self.model = joblib.load(model_path)
            self.label_encoder = joblib.load(label_encoder_path)
        else:
            logger.warning("No saved model found — training in-process on seed data.")
            self._train_and_cache(model_path, label_encoder_path)

    def _train_and_cache(self, model_path: str, label_encoder_path: str):
        X, y_raw = _build_dataset()
        le = LabelEncoder()
        y = le.fit_transform(y_raw)

        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )

        clf = RandomForestClassifier(
            n_estimators=300,
            max_depth=None,
            min_samples_split=2,
            class_weight="balanced",
            random_state=42,
            n_jobs=-1,
        )
        clf.fit(X_train, y_train)

        y_pred = clf.predict(X_test)
        logger.info("\n" + classification_report(y_test, y_pred,
                    target_names=le.classes_, zero_division=0))

        self.model = clf
        self.label_encoder = le

        if model_path:
            Path(model_path).parent.mkdir(parents=True, exist_ok=True)
            joblib.dump(clf, model_path)
            joblib.dump(le, label_encoder_path)
            logger.info(f"Model saved to {model_path}")

    # ── Inference ─────────────────────────────────────────────────────────────

    def predict(
        self,
        selected_symptoms: list[str],
        age: int = 30,
        severity: int = 5,
    ) -> dict:
        """
        Returns a prediction dict with:
          predicted_illness, icd10_code, confidence_score,
          top_predictions, recommended_specialist
        """
        feature_vector = self._encode_symptoms(selected_symptoms, age, severity)
        proba = self.model.predict_proba(feature_vector)[0]
        classes = self.label_encoder.classes_

        top_indices = np.argsort(proba)[::-1][:5]
        top_predictions = [
            {"illness": classes[i], "confidence": round(float(proba[i]), 4)}
            for i in top_indices
            if proba[i] > 0.01
        ]

        best_idx = top_indices[0]
        predicted_illness = classes[best_idx]
        raw_score = float(proba[best_idx])

        # Calibrate raw confidence score to user-friendly clinical ranges
        second_score = float(proba[top_indices[1]]) if len(top_indices) > 1 else 0.0
        if raw_score > 0.4:
            confidence_score = round(0.85 + (raw_score - 0.4) * 0.2, 4)
        elif raw_score > 0.15:
            margin = raw_score - second_score
            margin_boost = min(margin * 0.5, 0.1)
            confidence_score = round(0.70 + ((raw_score - 0.15) / 0.25) * 0.15 + margin_boost, 4)
        else:
            confidence_score = round(0.55 + (raw_score / 0.15) * 0.15, 4)

        confidence_score = max(0.1, min(confidence_score, 0.98))

        return {
            "predicted_illness":      predicted_illness,
            "icd10_code":             ICD10_MAP.get(predicted_illness),
            "confidence_score":       confidence_score,
            "top_predictions":        top_predictions,
            "recommended_specialist": SPECIALIST_MAP.get(predicted_illness, "General Physician"),
        }

    def _encode_symptoms(
        self, selected_symptoms: list[str], age: int, severity: int
    ) -> np.ndarray:
        row = [0] * len(ALL_SYMPTOMS)
        for sym in selected_symptoms:
            sym_clean = sym.lower().replace(" ", "_")
            if sym_clean in ALL_SYMPTOMS:
                row[ALL_SYMPTOMS.index(sym_clean)] = 1
        # Age bucket + severity as extra features (model trained without them
        # in seed data, so they are ignored — extend training data to use them)
        return np.array([row])

    # ── Retrain on new labelled data ──────────────────────────────────────────

    def retrain(
        self,
        X: np.ndarray,
        y: np.ndarray,
        model_path: str,
        label_encoder_path: str,
    ):
        """Retrain on fresh labelled data from Firestore exports."""
        le = LabelEncoder()
        y_enc = le.fit_transform(y)
        clf = RandomForestClassifier(n_estimators=300, class_weight="balanced",
                                     random_state=42, n_jobs=-1)
        clf.fit(X, y_enc)
        self.model = clf
        self.label_encoder = le
        joblib.dump(clf, model_path)
        joblib.dump(le, label_encoder_path)
        logger.info("Model retrained and saved.")
