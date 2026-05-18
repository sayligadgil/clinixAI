import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

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
      requiresVerification: (json['confidence'] ?? 1.0) < 0.40, // 🔹 Triggered by your 6-stage pipeline
      symptoms: List<String>.from(json['symptoms'] ?? []),
      assessment: json['ai_assessment'] ?? 'No assessment available.',
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
    );
  }

  // 🔹 Logic to determine UI color based on risk score or confidence
  Color get urgencyColor => riskScore > 0.8 || confidence < 0.40
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
  bool _isLoading = true;
  int _highPriorityCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  /// 🔹 BACKEND-DRIVEN: Fetch alerts based on Hospital ID isolation
  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final hospitalId = prefs.getString('hospital_id');

      // 🔹 Call GET /doctor/alerts endpoint
      final response = await dioClient.get(
        '/doctor/alerts',
        queryParameters: {
          'hospital_id': hospitalId,
          'status': 'unread',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final fetchedAlerts = data.map((json) => ClinixAlert.fromJson(json)).toList();

        setState(() {
          _alerts = fetchedAlerts;
          _highPriorityCount = _alerts.where((a) => a.confidence < 0.40).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Alert Fetch Error: $e");
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
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBB4f8v_RW8BZojSCSEwgiA04kxmsLA4h_H6qK0CRDn1zt-TEboQFmfzAY9zF17TOCm32uHm1W2OYHk8jJnKuAC9sBvMq2YJgnucQX0Vr3tgPH4otHuapEoFrUolb0wvL7kfXri74ZvPCuTZhX7so668ZZE0EUBC1e-raOlfE0WxhufmjkDs0C1Gxa4NPJh9Ir6xQSeneH61p-Etg2bffK6TdAqhf3gobAtA2IWuAHTI3JwWYSPtQ94hK5ZOHThm-_b-XcUdf1uUJ0'),
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
          onRefresh: _fetchAlerts,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const Text('Urgent Referrals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF191C20))),
              const SizedBox(height: 8),

              // 🔹 DYNAMIC COUNTER: From backend data
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

              // 🔹 DYNAMIC ALERT CARDS: No longer hardcoded
              if (_alerts.isEmpty)
                const Center(child: Text("No unread alerts for your facility."))
              else
                ..._alerts.map((alert) => Column(
                  children: [
                    AlertCard(alert: alert),
                    const SizedBox(height: 24),
                  ],
                )).toList(),
            ],
            ),
          ),
        ),
      ),
      // Bottom Navigation remains same UI...
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