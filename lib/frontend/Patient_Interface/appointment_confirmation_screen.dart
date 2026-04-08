import 'package:flutter/material.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),

      // ── AppBar ───────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE6E8ED),
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Confirmation Hero ──────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC2E8FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF004976),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Appointment confirmed!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF004976),
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Finding the best specialist...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF414750),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── AI Clinical Matching Card ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFC2E8FF).withOpacity(0.35),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.psychology_outlined,
                          color: Color(0xFF004976), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'AI CLINICAL MATCHING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF004976),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Step 1 - Active
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF004976),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Symptom Analysis',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF004976),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Scanning cardiovascular patterns\n& medical history',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF414750),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Step 2 - Dimmed
                  Opacity(
                    opacity: 0.4,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFF004976).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registry Check',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF414750),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Cross-referencing hospital board\ncertifications',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF414750),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Doctor Card ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFC0C7D1).withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor photo placeholder
                  Container(
                    width: 90,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEEF3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCEE5FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'TOP MATCHED SPECIALIST',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF004A77),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Dr. Elena Rodriguez',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF191C20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Cardiologist at St. Mary's General",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF004976),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.star, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '4.9 (120+ reviews)',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.verified_outlined,
                                size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              '15 yrs experience',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Appointment Itinerary ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appointment Itinerary',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _itineraryIcon(Icons.calendar_today_outlined),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tuesday, Oct 24 • 10:30 AM',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _itineraryIcon(Icons.location_on_outlined),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "St. Mary's General, Wing B",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Add to Calendar Button ─────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: add to calendar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004976),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: const Color(0xFF004976).withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available_outlined, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Add to Calendar',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Nav ────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.home,
                  label: 'Home',
                  active: true,
                  onTap: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                ),
                _navItem(
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

  Widget _itineraryIcon(IconData icon) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
        ),
      ],
    ),
    child: Icon(icon, color: const Color(0xFF004976), size: 22),
  );

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFF004976) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? const Color(0xFF004976) : Colors.grey,
              ),
            ),
          ],
        ),
      );
}