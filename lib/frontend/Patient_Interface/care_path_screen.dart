import 'package:flutter/material.dart';
import 'checkout_screen.dart';
import 'appointment_confirmation_screen.dart';
import 'package:clinixai/backend/app/models/care_path.dart';
import 'package:clinixai/backend/app/models/appointment.dart';
import 'package:clinixai/backend/app/models/consultation.dart';

class CarePathScreen extends StatelessWidget {
  final String patientName;
  final int severity;
  final List<String> selectedSymptoms;
  final CarePathData analysisResult;

  const CarePathScreen({
    super.key,
    required this.patientName,
    required this.severity,
    required this.selectedSymptoms,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha((0.85 * 255).round()),
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Color(0xFF004976)),
            ),
            const SizedBox(width: 12),
            const Text(
              'CliniX AI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF00629B),
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE6E8ED),
              child: Icon(Icons.person, size: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis complete.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF004976),
                letterSpacing: -1,
                height: 1.2,
              ),
            ),
            const Text(
              'How would you like to proceed?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Color(0xFF414750),
                letterSpacing: -0.5,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 28),

            // Analysis Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFFC0C7D1).withAlpha((0.4 * 255).round())),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha((0.04 * 255).round()),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Analysis Summary',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 17)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCEE5FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('LIVE REPORT',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF004A77),
                                letterSpacing: 1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('Likely Condition:',
                          style: TextStyle(
                              color: Color(0xFF414750),
                              fontWeight: FontWeight.w500)),
                      Text(analysisResult.diagnosis,
                          style: const TextStyle(
                              color: Color(0xFF004976),
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AI Confidence',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF414750))),
                      Text('${(analysisResult.confidence * 100).toStringAsFixed(0)}% Match',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFF004976))),
                    if (analysisResult.confidence < 0.5)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Analysis uncertain, please consult a doctor.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: analysisResult.confidence,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE6E8ED),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF004976)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    analysisResult.analysisDetail,
                    style: const TextStyle(
                        color: Color(0xFF414750), fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'We have prepared two distinct care paths. Choose the one that best fits your current urgency.',
              style: TextStyle(
                  color: Color(0xFF414750), fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),

            // ── AI Prescription Card ───────────────────────────
            GestureDetector(
              onTap: () {
                final consultationToPay = ConsultationData(
                  sessionId: "SES-${DateTime.now().millisecondsSinceEpoch}",
                  patientName: patientName,
                  hospitalName: analysisResult.hospitalName,
                  diagnosis: analysisResult.diagnosis,
                  confidence: analysisResult.confidence,
                  medications: [], // Initially empty, populated after payment/API call
                  consultationId: analysisResult.consultationId,
                  doctorName: analysisResult.doctorName ?? "Dr. Ramesh Babu Katta",
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(consultation: consultationToPay),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2E8FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.psychology, color: Color(0xFF004976), size: 28),
                    const SizedBox(height: 20),
                    const Text('Generate AI Prescription',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text('Best for non-emergency ailments.', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 24),
                    Text('₹${analysisResult.prescriptionPrice} INR',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF004976))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Book Appointment Card ──────────────────────────
            GestureDetector(
              onTap: () {
                final tempAppointment = AppointmentData(
                  doctorName: analysisResult.doctorName ?? "Dr. Ramesh Babu Katta",
                  specialization: analysisResult.specialization ?? "General Physician",
                  hospitalName: analysisResult.hospitalName,
                  hospitalLocation: "Specialist Wing",
                  appointmentTime: "Tomorrow, 10:30 AM",
                  patientSymptoms: selectedSymptoms,
                  details: analysisResult.analysisDetail,
                  doctorUid: analysisResult.doctorUid,
                  hospitalId: analysisResult.hospitalId,
                  consultationId: analysisResult.consultationId,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentConfirmationScreen(appointment: tempAppointment),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: Color(0xFF006688), size: 28),
                    const SizedBox(height: 20),
                    const Text('Book an Appointment',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text('Schedule a visit with a specialist.', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 24),
                    Text("Nearest: ${analysisResult.hospitalName}",
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Tip Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Unsure which to choose?',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text('Our AI model suggests a ${(analysisResult.confidence * 100).toStringAsFixed(0)}% match.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF414750))),
                  const SizedBox(height: 20),
                  Row(
                    children: const [
                      _TrustBadge(icon: Icons.verified_user, label: 'HIPAA Compliant'),
                      SizedBox(width: 20),
                      _TrustBadge(icon: Icons.lock, label: '256-bit Encryption'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  active: true,
                  onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  active: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF004976)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF00629B) : Colors.grey),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: active ? const Color(0xFF00629B) : Colors.grey)),
        ],
      ),
    );
  }
}