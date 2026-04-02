import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class CarePathScreen extends StatelessWidget {
  final String patientName;
  final int severity;
  final List<String> selectedSymptoms;

  const CarePathScreen({
    super.key,
    required this.patientName,
    required this.severity,
    required this.selectedSymptoms,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),

      // ── Top App Bar ──────────────────────────────────────────
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

            // ── Hero Header ────────────────────────────────────
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

            // ── Analysis Summary Card ──────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFC0C7D1).withOpacity(0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Analysis Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCEE5FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'LIVE REPORT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF004A77),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Likely condition
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        'Likely Condition:',
                        style: TextStyle(
                          color: Color(0xFF414750),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Seasonal Allergies',
                        style: TextStyle(
                          color: Color(0xFF004976),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Confidence bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'AI Confidence',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF414750),
                        ),
                      ),
                      Text(
                        '78% Match',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF004976),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: 0.78,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE6E8ED),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF004976)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Based on your reported respiratory symptoms and ocular irritation, our clinical model indicates a high probability of allergic rhinitis triggered by seasonal environmental factors.',
                    style: TextStyle(
                      color: Color(0xFF414750),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Subtitle ───────────────────────────────────────
            const Text(
              'We have prepared two distinct care paths. Choose the one that best fits your current urgency.',
              style: TextStyle(
                color: Color(0xFF414750),
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // ── AI Prescription Card ───────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFFC2E8FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    // Decorative blur circle
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.psychology,
                              color: Color(0xFF004976), size: 28),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Generate AI Prescription',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF001E2B),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pay for a secure, AI-powered analysis and prescription. Best for non-emergency common ailments.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF004D67),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.payments_outlined,
                                      size: 16,
                                      color: Color(0xFF004976)),
                                  SizedBox(width: 6),
                                  Text(
                                    '\$24.99 USD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Color(0xFF004976),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF004976),
                                    Color(0xFF00629B)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF004976)
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Book Appointment Card ──────────────────────────
            GestureDetector(
              onTap: () {
                // TODO: navigate to appointment screen
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
                    // Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.calendar_month_outlined,
                          color: Color(0xFF006688), size: 28),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Book an Appointment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF191C20),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Schedule a visit with a specialist at your chosen hospital. Recommended for physical exams and chronic care.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF414750),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: Color(0xFF006688)),
                              SizedBox(width: 6),
                              Text(
                                "Nearest: St. Mary's",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF191C20),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Tip Card ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 12, color: Color(0xFF343D96)),
                        SizedBox(width: 6),
                        Text(
                          'QUICK TIP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF343D96),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unsure which to choose?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF191C20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Color(0xFF414750),
                        fontSize: 13,
                        height: 1.6,
                      ),
                      children: [
                        TextSpan(
                            text:
                            'Our AI model suggests a '),
                        TextSpan(
                          text: '78% match',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF004976),
                          ),
                        ),
                        TextSpan(
                            text:
                            ' for seasonal allergies. The AI Prescription path can provide immediate relief with standard over-the-counter or non-controlled medication recommendations.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trust badges
                  Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: const [
                      _TrustBadge(
                        icon: Icons.verified_user,
                        label: 'HIPAA Compliant',
                      ),
                      _TrustBadge(
                        icon: Icons.lock,
                        label: '256-bit Encryption',
                      ),
                    ],
                  ),
                ],
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
            const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home — goes back to UserSelectionScreen
                _NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  active: true,
                  onTap: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
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

// ── Trust Badge Widget ────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF004976), size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF414750),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Nav Item Widget ───────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}