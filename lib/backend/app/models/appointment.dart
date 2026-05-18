class AppointmentData {
  final String doctorName;
  final String specialization;
  final String hospitalName;
  final String hospitalLocation;
  final String appointmentTime; // e.g., "Tuesday, Oct 24 • 10:30 AM"
  final double rating;
  final int reviews;
  final int experienceYears;
  final String matchedReason;
  final String? doctorUid;
  final String? hospitalId;
  final String? consultationId;

  AppointmentData({
    required this.doctorName,
    required this.specialization,
    required this.hospitalName,
    required this.hospitalLocation,
    required this.appointmentTime,
    required this.rating,
    required this.reviews,
    required this.experienceYears,
    required this.matchedReason,
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
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['review_count'] ?? 0,
      experienceYears: json['experience_years'] ?? 0,
      matchedReason: json['match_logic_summary'] ?? "Scanning medical patterns",
      doctorUid: json['doctor_uid']?.toString(),
      hospitalId: json['hospital_id']?.toString(),
      consultationId: json['consultation_id']?.toString(),
    );
  }
}