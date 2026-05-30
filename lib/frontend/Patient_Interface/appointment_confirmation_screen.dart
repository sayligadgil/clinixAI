import 'package:flutter/material.dart';
import 'package:clinixai/backend/app/models/appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class AppointmentConfirmationScreen extends StatefulWidget {
  final AppointmentData appointment;

  const AppointmentConfirmationScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentConfirmationScreen> createState() => _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState extends State<AppointmentConfirmationScreen> {
  bool _isBooking = false;

  Future<void> _bookAppointment() async {
    setState(() => _isBooking = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not signed in. Please restart the app.');
      }
      final idToken = await user.getIdToken();
      final patientUid = user.uid;

      // Call live POST /patient/appointment
      final response = await dioClient.post(
        '/patient/appointment',
        data: {
          'consultation_id': widget.appointment.consultationId ?? 'c_default',
          'patient_uid': patientUid,
          'doctor_uid': widget.appointment.doctorUid ?? 'doc_ramesh_uid',
          'preferred_doctor_uid': widget.appointment.doctorUid ?? 'doc_ramesh_uid',
          'hospital_id': widget.appointment.hospitalId ?? 'HOSP_001',
          'preferred_date': DateTime.now().toString().substring(0, 10),
          'preferred_time': '10:30 AM',
          'reason': widget.appointment.details ?? 'General consultation',
        },
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📅 Appointment successfully added to calendar and synced with Doctor dashboard!'),
              backgroundColor: Color(0xFF004976),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/user_selection', (route) => false);
          }
        }
      } else {
        throw Exception('Failed to schedule appointment');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Scheduling failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

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
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC2E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF004976), size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Appointment confirmed!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF004976), letterSpacing: -0.8),
                  ),
                  const SizedBox(height: 6),
                  const Text('Finding the best specialist...', style: TextStyle(fontSize: 16, color: Color(0xFF414750))),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFC2E8FF).withOpacity(0.35), borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.psychology_outlined, color: Color(0xFF004976), size: 20),
                      SizedBox(width: 8),
                      Text('AI CLINICAL MATCHING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF004976), letterSpacing: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 4, height: 52, decoration: BoxDecoration(color: const Color(0xFF004976), borderRadius: BorderRadius.circular(999))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Symptom Analysis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF004976))),
                            const SizedBox(height: 4),
                            Text(widget.appointment.details ?? 'General consultation',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF414750), height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: 0.4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 4, height: 52, decoration: BoxDecoration(color: const Color(0xFF004976).withOpacity(0.3), borderRadius: BorderRadius.circular(999))),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Registry Check', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF414750))),
                            SizedBox(height: 4),
                            Text('Cross-referencing hospital board\ncertifications', style: TextStyle(fontSize: 11, color: Color(0xFF414750), height: 1.4)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC0C7D1).withAlpha((0.2 * 255).round())),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.04 * 255).round()), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 90, height: 110,
                    decoration: BoxDecoration(color: const Color(0xFFECEEF3), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.person, size: 48, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFCEE5FF), borderRadius: BorderRadius.circular(999)),
                          child: const Text('TOP MATCHED SPECIALIST', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF004A77), letterSpacing: 0.8)),
                        ),
                        const SizedBox(height: 10),
                        Text(widget.appointment.doctorName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF191C20))),
                        const SizedBox(height: 4),
                        Text("${widget.appointment.specialization} at ${widget.appointment.hospitalName}",
                            style: const TextStyle(fontSize: 13, color: Color(0xFF004976), fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        const SizedBox(height: 4),
                        const Text('Specialist details are available in the doctor profile.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFFF2F3F9), borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Appointment Itinerary', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _itineraryIcon(Icons.calendar_today_outlined),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date & Time', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(widget.appointment.appointmentTime,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _itineraryIcon(Icons.location_on_outlined),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Location', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text("${widget.appointment.hospitalName}, ${widget.appointment.hospitalLocation}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004976),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: const Color(0xFF004976).withOpacity(0.3),
                ),
                child: _isBooking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.event_available_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Add to Calendar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _itineraryIcon(IconData icon) => Container(
    width: 48, height: 48,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
    child: Icon(icon, color: const Color(0xFF004976), size: 22),
  );

  Widget _buildBottomNav(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.home, label: 'Home', active: true, onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/user_selection', (route) => false)),
            _navItem(icon: Icons.settings_outlined, label: 'Settings', active: false, onTap: () {}),
          ],
        ),
      ),
    ),
  );

  Widget _navItem({required IconData icon, required String label, required bool active, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? const Color(0xFF004976) : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? const Color(0xFF004976) : Colors.grey)),
          ],
        ),
      );
}