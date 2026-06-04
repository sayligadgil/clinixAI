import io
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch

def generate_prescription_pdf(data: dict) -> bytes:
    """
    Generates a professional PDF for the CliniX AI prescription.
    """
    buffer = io.BytesIO()
    p = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter

    # Header
    p.setFont("Helvetica-Bold", 22)
    p.drawCentredString(width / 2.0, height - 1*inch, "CliniX AI Digital Prescription")

    p.setFont("Helvetica", 12)
    p.drawCentredString(width / 2.0, height - 1.3*inch, f"Hospital: {data.get('hospital_name', 'Partner Hospital')}")
    p.line(0.5*inch, height - 1.5*inch, 8*inch, height - 1.5*inch)

    # Patient Info
    p.setFont("Helvetica-Bold", 12)
    p.drawString(1*inch, height - 2*inch, f"Patient Name: {data.get('patient_name', 'N/A')}")
    p.drawString(1*inch, height - 2.2*inch, f"Diagnosis: {data.get('diagnosis', 'N/A')}")
    p.drawString(1*inch, height - 2.4*inch, f"Date: {data.get('issued_at', 'N/A')[:10]}")

    # Medications
    p.drawString(1*inch, height - 3*inch, "Medications:")
    p.setFont("Helvetica", 11)
    y = height - 3.3*inch
    
    medications = data.get('medications', [])
    if not medications:
        p.setFillColorRGB(0.8, 0, 0) # Red color
        p.drawString(1.2*inch, y, "⚠️ REQUIRES IMMEDIATE DOCTOR REVIEW.")
        p.drawString(1.2*inch, y - 0.2*inch, "Automated prescription withheld for safety.")
        p.setFillColorRGB(0, 0, 0) # Reset color
    else:
        for med in medications:
            med_str = f"• {med.get('name')} - {med.get('dosage')} ({med.get('frequency')}) for {med.get('duration_days')} days"
            p.drawString(1.2*inch, y, med_str)
            y -= 0.2*inch

    # Footer Disclaimer
    p.setFont("Helvetica-Oblique", 10)
    p.drawCentredString(width / 2.0, 1*inch, "This is an AI-generated prescription and MUST be reviewed by a registered medical practitioner.")

    p.showPage()
    p.save()

    buffer.seek(0)
    return buffer.getvalue()