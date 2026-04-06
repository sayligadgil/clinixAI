import 'dart:ui';
import 'package:flutter/material.dart';
import 'doctor_schedule_screen.dart';
import 'doctor_history.dart';
import 'doctor_notifs.dart';
import 'doctor_ai_log.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;

  // Custom colors from Tailwind config
  static const Color secondaryFixed = Color(0xFFC2E8FF);
  static const Color onSecondaryFixed = Color(0xFF001E2B);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3F9);
  static const Color surfaceContainerHigh = Color(0xFFE6E8ED);
  static const Color surfaceContainer = Color(0xFFECEEF3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: _selectedIndex == 0
          ? CustomScrollView(
              slivers: [
                // TopAppBar
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFF191C20).withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuD5x8cb_7dr9FAyveWyGOKwtr5zpetSfWNdZWCvnTGyrZmyCCMLCjlWrL9voYbkqwOGQm_VYN1bza55ZkaIQ69FdAlyCk-L-BJPLiUlAqNSzwetROQ49ubX82H6F7R4IQSHskYXqYXVdogSfiM6mfDi9xfaEP0ihYja59Pgp87l8hp5EZe12xJbtJMPaJeqSvx9QtnQVYjNLI0GiNdxPXPRJXWGWpYy4oX1oOFSzqnDyf62ibYYzEZzxLUAvh8b-nDOJrrpSkJeDAc',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: surfaceContainer);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'CliniX AI',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00629B),
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          color: Colors.grey[600],
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AlertDashboard(),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFBA1A1A),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom: 120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Section
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search patients, records, symptoms...',
                              hintStyle: TextStyle(
                                color: const Color(0xFF717881).withOpacity(0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF717881),
                              ),
                              filled: true,
                              fillColor: surfaceContainerLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      const Color(0xFF004976).withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        // Main Content Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            bool isDesktop = constraints.maxWidth > 1024;

                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 8,
                                    child: _buildUpcomingAppointments(),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    flex: 4,
                                    child: _buildAlertCases(),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildUpcomingAppointments(),
                                  const SizedBox(height: 32),
                                  _buildAlertCases(),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : _selectedIndex == 1
              ? const DoctorScheduleScreen()
              : _selectedIndex == 2
                  ? const PatientHistoryScreen()
                  : _selectedIndex == 3
                      ? const PrescriptionLogPage()
                      : const SizedBox(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF004976),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF004976),
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Today, Oct 24',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF414750),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            bool showGrid = constraints.maxWidth > 600;

            if (showGrid) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildAppointmentCard1(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildAppointmentCard2(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAppointmentCard3(),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildAppointmentCard1(),
                  const SizedBox(height: 16),
                  _buildAppointmentCard2(),
                  const SizedBox(height: 16),
                  _buildAppointmentCard3(),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentCard1() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: secondaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '09:30 AM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: onSecondaryFixed,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                color: const Color(0xFF717881),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sarah Henderson',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191C20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Routine Follow-up • Chronic Hypertension',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF414750),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description,
                  size: 16,
                  color: Color(0xFF191C20),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'View medical history',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF004976),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard2() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: secondaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '10:15 AM',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: onSecondaryFixed,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Icon(
                Icons.more_vert,
                color: const Color(0xFF717881),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Marcus Thorne',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF191C20),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Urgent Consultation • Acute Migraine',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF414750),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt,
                  size: 16,
                  color: Color(0xFF191C20),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Pre-diagnosis available',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF004976),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard3() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 500;

          if (isWide) {
            return Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCjLmnatKpY9qHTmPspKrwUplRvno4ON9fn7Wg5bJRvdunboQUYXYyiTNx9-SYChYIspw51tX3soqiMBrdkbcAb7CGGCX-U2rwS3HeLvdKyGw6on6as4hBk8m96xtBnDjXHfClxXCuV4UtDCZKuiwJsKOC9FmyvbOWMULEaUFW6s-W9oC5huQ66r6QdzPICajqBDB_uMuvKi8IbICa5Y7RkfwG75FfhUb5RwrzJfgD8IrFQMyYgW4wR7eYRDRuvL7lFCnxu69huSKs',
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 128,
                        height: 128,
                        color: surfaceContainerHigh,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(child: _buildAppointmentCard3Content()),
              ],
            );
          } else {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCjLmnatKpY9qHTmPspKrwUplRvno4ON9fn7Wg5bJRvdunboQUYXYyiTNx9-SYChYIspw51tX3soqiMBrdkbcAb7CGGCX-U2rwS3HeLvdKyGw6on6as4hBk8m96xtBnDjXHfClxXCuV4UtDCZKuiwJsKOC9FmyvbOWMULEaUFW6s-W9oC5huQ66r6QdzPICajqBDB_uMuvKi8IbICa5Y7RkfwG75FfhUb5RwrzJfgD8IrFQMyYgW4wR7eYRDRuvL7lFCnxu69huSKs',
                    width: double.infinity,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 128,
                        color: surfaceContainerHigh,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildAppointmentCard3Content(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentCard3Content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: secondaryFixed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '11:30 AM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: onSecondaryFixed,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Text(
              'LAB REVIEW REQUIRED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFBA1A1A),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Eleanor Vance',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF191C20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Post-operative review for cardiac stent placement. Recent blood work indicates elevated CRP levels.',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF414750),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004976), Color(0xFF00629B)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  'Prepare Documents',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alert Cases',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF004976),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'AI-prioritized urgent reviews',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF414750),
          ),
        ),
        const SizedBox(height: 24),

        // Critical Alert Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFC2E8FF), Color(0xFFF8F9FF)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA1A1A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      color: Color(0xFFBA1A1A),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Johnathan Doe',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191C20),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CRITICAL ALERT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF414750),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.emergency,
                    color: Color(0xFFBA1A1A),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'AI detected irregular heart rhythm patterns in wearable data from the last 4 hours. Suggest immediate callback.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF191C20),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBA1A1A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Call Now',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF191C20),
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Diagnostic Match Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004976).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Color(0xFF004976),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aria Stark',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF191C20),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'DIAGNOSTIC MATCH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF414750),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Lab results for Aria (Case #882) show a 94% correlation with Type-II Diabetes progression markers.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF191C20),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Review AI Data Log',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF004976),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF004976),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Quick Stats
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EFFICIENCY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF414750),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '92%',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF004976),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUEUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF414750),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '12',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF004976),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C20).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF004976),
            unselectedItemColor: Colors.grey[500],
            selectedFontSize: 10,
            unselectedFontSize: 10,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0xFFC2E8FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 1
                      ? Icons.calendar_month
                      : Icons.calendar_month_outlined,
                ),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 2 ? Icons.history : Icons.history_outlined,
                ),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 3
                      ? Icons.psychology
                      : Icons.psychology_outlined,
                ),
                label: 'AI Log',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 4
                      ? Icons.settings
                      : Icons.settings_outlined,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
