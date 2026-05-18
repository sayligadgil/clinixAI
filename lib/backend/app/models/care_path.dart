class CarePathData {
  final String diagnosis;
  final double confidence;
  final String analysisDetail;
  final String hospitalName;
  final double prescriptionPrice;
  final String? consultationId;
  final String? doctorName;
  final String? doctorUid;
  final String? specialization;
  final String? hospitalId;

  CarePathData({
    required this.diagnosis,
    required this.confidence,
    required this.analysisDetail,
    required this.hospitalName,
    this.prescriptionPrice = 24.99,
    this.consultationId,
    this.doctorName,
    this.doctorUid,
    this.specialization,
    this.hospitalId,
  });

  factory CarePathData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CarePathData(
      diagnosis: json['diagnosis']?.toString() ?? 
                 json['predicted_illness']?.toString() ?? 
                 json['likely_condition']?.toString() ?? 
                 'Unknown',
      confidence: parseDouble(json['confidence'] ?? json['confidence_score']),
      analysisDetail: json['analysis_detail']?.toString() ?? 
                      json['analysis_notes']?.toString() ?? 
                      json['reasoning']?.toString() ?? 
                      '',
      prescriptionPrice: parseDouble(json['price'] ?? json['prescription_price'] ?? 24.99),
      hospitalName: json['hospital_name']?.toString() ?? 
                    json['hospital_id']?.toString() ?? 
                    'Medical Center',
      consultationId: json['consultation_id']?.toString(),
      doctorName: json['matched_doctor_name']?.toString(),
      doctorUid: json['matched_doctor_uid']?.toString(),
      specialization: json['recommended_spec']?.toString(),
      hospitalId: json['hospital_id']?.toString(),
    );
  }
}