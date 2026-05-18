import 'package:flutter/material.dart';
import 'user_selection_screen.dart';
import 'package:clinixai/backend/app/models/consultation.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PrescriptionScreen extends StatelessWidget {
  // 🔹 DATA REQUIREMENT
  final ConsultationData consultation;

  const PrescriptionScreen({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF004976)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CliniX AI",
          style: TextStyle(
            color: Color(0xFF00629B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Digital Prescription",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004976),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Session ID: ${consultation.sessionId}", // 🔹 DYNAMIC ID
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // 🔹 PATIENT + HOSPITAL CARD
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Patient Details",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    consultation.patientName, // 🔹 DYNAMIC PATIENT
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text("Demographics: Auto-fetched from Profile"),
                  const SizedBox(height: 20),
                  const Text("Issued By",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    consultation.hospitalName, // 🔹 DYNAMIC HOSPITAL
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004976)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 AI RESULT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFC2E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.psychology, color: Color(0xFF004976)),
                      SizedBox(width: 8),
                      Text(
                        "AI Diagnostic Result",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004976)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    consultation.diagnosis, // 🔹 DYNAMIC DIAGNOSIS
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Confidence: ${(consultation.confidence * 100).toStringAsFixed(1)}%", // 🔹 FORMATTED CONFIDENCE
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 PRESCRIBING PRACTITIONER CARD (Same size/style as medications card below)
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Prescribing Practitioner",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFFCEE5FF),
                        child: const Icon(Icons.person, size: 28, color: Color(0xFF004976)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consultation.doctorName ?? "Dr. Ramesh Babu Katta",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF004976)),
                            ),
                            const Text(
                              "Clinical AI Specialist",
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 MEDICATION LIST
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Suggested Medications",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // 🔹 DYNAMIC MAPPING OF DATABASE RULES
                  ...consultation.medications.map((med) => _medTile(
                    title: "${med.name} (${med.dosage})",
                    desc: "${med.frequency} for ${med.duration}",
                    qty: med.qty,
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 DISCLAIMER
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This prescription is AI-assisted and follows hospital protocols.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 DOWNLOAD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final rxId = consultation.consultationId;
                  if (rxId == null || rxId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error: No prescription reference found to download."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  final String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
                  final Uri url = Uri.parse("$baseUrl/patient/prescription/$rxId/pdf");
                  
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      await launchUrl(url, mode: LaunchMode.platformDefault);
                    }
                  } catch (e) {
                    debugPrint("Could not launch $url: $e");
                    try {
                      await launchUrl(url, mode: LaunchMode.inAppWebView);
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Could not open PDF download link: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download),
                label: const Text("Download PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004976),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserSelectionScreen()),
                      (route) => false,
                );
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Color(0xFF004976)),
                  Text("Home"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _medTile extends StatelessWidget {
  final String title;
  final String desc;
  final String qty;

  const _medTile({
    required this.title,
    required this.desc,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(qty,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}