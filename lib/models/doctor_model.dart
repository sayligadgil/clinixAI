class DoctorModel {
  final String id;
  final String name;
  final String hospitalId;
  final String specialization;
  final List<String> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.hospitalId,
    required this.specialization,
    required this.availableSlots,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      hospitalId: json['hospital_id']?.toString() ?? '',
      specialization: json['specialization']?.toString() ?? '',
      availableSlots: (json['available_slots'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hospital_id': hospitalId,
    'specialization': specialization,
    'available_slots': availableSlots,
  };
}
