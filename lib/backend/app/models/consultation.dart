class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String qty;

  Medication({required this.name, required this.dosage, required this.frequency, required this.duration, required this.qty});

  factory Medication.fromJson(Map<String, dynamic> json) {
    final durationVal = json['duration_days'] ?? json['duration'];
    final durationStr = durationVal != null ? (durationVal.toString().contains("days") ? durationVal.toString() : "$durationVal days") : "As prescribed";
    return Medication(
      name: json['name']?.toString() ?? 'Medication',
      dosage: json['dosage']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      duration: durationStr,
      qty: json['qty']?.toString() ?? "As prescribed",
    );
  }
}

class ConsultationData {
  final String sessionId;
  final String patientName;
  final String hospitalName;
  final String diagnosis;
  final double confidence;
  final List<Medication> medications;
  final String? consultationId;
  final String? doctorName;

  ConsultationData({
    required this.sessionId,
    required this.patientName,
    required this.hospitalName,
    required this.diagnosis,
    required this.confidence,
    required this.medications,
    this.consultationId,
    this.doctorName,
  });
}