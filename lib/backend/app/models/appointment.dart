class AppointmentData {
  final String doctorName;
  final String specialization;
  final String hospitalName;
  final String hospitalLocation;
  final String appointmentTime; // e.g., "Tuesday, Oct 24 • 10:30 AM"
  final List<String> patientSymptoms; // new field
  final String details; // new field for additional info
  final String? doctorUid;
  final String? hospitalId;
  final String? consultationId;

  AppointmentData({
    required this.doctorName,
    required this.specialization,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.appointmentTime,
    required this.patientSymptoms,
    required this.details,
    this.doctorUid,
    this.hospitalId,
    this.consultationId,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    return AppointmentData(
      doctorName: json['doctor_name'] ?? "Specialist",
      specialization: json['specialization'] ?? "Medical Expert",
      hospitalName: json['hospital_name'] ?? "Medical Center",
      hospitalLocation: json['location_detail'] ?? "Main Wing",
      appointmentTime: json['appointment_slot'] ?? "TBD",
      patientSymptoms: (json['patient_symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      details: json['details'] ?? "",
      doctorUid: json['doctor_uid']?.toString(),
      hospitalId: json['hospital_id']?.toString(),
      consultationId: json['consultation_id']?.toString(),
    );
  }
}