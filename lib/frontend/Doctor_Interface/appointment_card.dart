import 'package:flutter/material.dart';

// Data model for appointments fetched from backend
class ClinixAppointment {
  final String patientName;
  final String time;
  final String reason;
  final String type;

  ClinixAppointment({required this.patientName, required this.time, required this.reason, required this.type});

  factory ClinixAppointment.fromJson(Map<String, dynamic> json) {
    return ClinixAppointment(
      patientName: json['patient_name'] ?? 'Unknown',
      time: json['time'] ?? '10:00 AM',
      reason: json['reason'] ?? 'Consultation',
      type: json['type'] ?? 'General',
    );
  }
}

// Widget to render an appointment card in the doctor dashboard
class AppointmentCard extends StatelessWidget {
  final ClinixAppointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Color(0xFF004976)),
        title: Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${appointment.reason} • ${appointment.time}'),
        trailing: Text(appointment.type, style: const TextStyle(color: Color(0xFF006688))),
        onTap: () {},
      ),
    );
  }
}
