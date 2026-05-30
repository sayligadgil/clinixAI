import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import 'appointment_card.dart';

// 🔹 Added Data Model for AlertResponse
class ClinixAlert {
  final String id;
  final String patientName;
  final String timestamp;
  final double confidence;
  final bool requiresVerification;
  final List<String> symptoms;
  final String assessment;
  final double riskScore;

  ClinixAlert({
    required this.id,
    required this.patientName,
    required this.timestamp,
    required this.confidence,
    required this.requiresVerification,
    required this.symptoms,
    required this.assessment,
    required this.riskScore,
  });

  factory ClinixAlert.fromJson(Map<String, dynamic> json) {
    return ClinixAlert(
      id: json['alert_id'] ?? '',
      patientName: json['patient_name'] ?? 'Unknown Patient',
      timestamp: json['received_at'] ?? 'Just now',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      requiresVerification: (json['confidence'] ?? 1.0) < 0.60, // 🔹 Triggered by your 6-stage pipeline
      symptoms: List<String>.from(json['symptoms'] ?? []),
      assessment: json['ai_assessment'] ?? 'No assessment available.',
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
    );
  }

  // 🔹 Logic to determine UI color based on risk score or confidence
  Color get urgencyColor => riskScore > 0.8 || confidence < 0.60
    ? const Color(0xFFBA1A1A)
    : const Color(0xFFF97316);
}

class AlertDashboard extends StatefulWidget {
  const AlertDashboard({super.key});

  @override
  State<AlertDashboard> createState() => _AlertDashboardState();
}

class _AlertDashboardState extends State<AlertDashboard> {
  List<ClinixAlert> _alerts = [];
  List<ClinixAppointment> _appointments = [];
  bool _isLoading = true;
  int _highPriorityCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// 🔹 BACKEND-DRIVEN: Fetch data based on User and Hospital context
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final hospitalId = prefs.getString('hospital_id');
      final doctorUid = prefs.getString('doctor_uid');

      // Fetch alerts
      final alertResp = await dioClient.get(
        '/doctor/alerts',
        queryParameters: {'hospital_id': hospitalId, 'status': 'unread'},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (alertResp.statusCode == 200) {
        final List<dynamic> data = alertResp.data;
        _alerts = data.map((json) => ClinixAlert.fromJson(json)).toList();
        _highPriorityCount = _alerts.where((a) => a.confidence < 0.60).length;
      }

      // Fetch appointments
      final apptResp = await dioClient.get(
        '/doctor/appointments/$doctorUid',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (apptResp.statusCode == 200) {
        final List<dynamic> data = apptResp.data;
        _appointments = data.map((json) => ClinixAppointment.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("❌ Dashboard fetch error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFCEE5FF),
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Dr+Ramesh&background=0D8ABC&color=fff'),
            ),
            const SizedBox(width: 12),
            Text(
              'CliniX AI Alerts',
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Urgent Referrals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF191C20))),
              const SizedBox(height: 8),

              // 🔹 DYNAMIC COUNTER
              if (_highPriorityCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_rounded, size: 14, color: Color(0xFF93000A)),
                      const SizedBox(width: 6),
                      Text(
                        '$_highPriorityCount HIGH PRIORITY CASES DETECTED',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF93000A)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // 🔹 DYNAMIC ALERT CARDS
              if (_alerts.isEmpty)
                const Center(child: Text("No unread alerts for your facility."))
              else
                ..._alerts.map((alert) => Column(
                  children: [
                    AlertCard(alert: alert),
                    const SizedBox(height: 24),
                  ],
                )).toList(),

              // New: Appointments Section
              const SizedBox(height: 32),
              const Text('Upcoming Appointments', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF191C20))),
              const SizedBox(height: 8),
              if (_appointments.isEmpty)
                const Center(child: Text("No upcoming appointments."))
              else
                ..._appointments.map((appt) => Column(
                  children: [
                    AppointmentCard(appointment: appt),
                    const SizedBox(height: 24),
                  ],
                )).toList(),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final ClinixAlert alert;

  const AlertCard({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0, top: 0, bottom: 0, width: 6,
              child: Container(color: alert.urgencyColor), // 🔹 DATABASE DRIVEN COLOR
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alert.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          Text(alert.timestamp, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              'Confidence: ${(alert.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF93000A)),
                            ),
                          ),
                          if (alert.requiresVerification)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('Requires Manual Verification', style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.grey)),
                            ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: alert.symptoms.map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF006688))),
                      backgroundColor: const Color(0xFFECEEF3),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildAIAssessment(alert.assessment),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004976), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('View Case'))),
                      const SizedBox(width: 12),
                      Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Mark Attended'))),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssessment(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC2E8FF), Color(0xFFF2F3F9)]), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Row(children: [Icon(Icons.psychology, size: 16, color: Color(0xFF004976)), SizedBox(width: 8), Text('AI ASSESSMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))]),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}