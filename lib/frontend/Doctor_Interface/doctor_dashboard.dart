import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:clinixai/backend/app/models/appointment.dart';
import '../../core/api_client.dart';

// 🔹 Import existing screens
import 'doctor_schedule_screen.dart';
import 'doctor_history.dart';
import 'doctor_notifs.dart';
import 'doctor_ai_log.dart';

// 🔹 Models for Backend Data
class Appointment {
  final String patientName;
  final String time;
  final String reason;
  final String type;

  Appointment({required this.patientName, required this.time, required this.reason, required this.type});

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    patientName: json['patient_name'],
    time: json['time'],
    reason: json['reason'],
    type: json['type'],
  );
}

class AlertCase {
  final String patientName;
  final String alertType;
  final String description;
  final double riskScore;

  AlertCase({required this.patientName, required this.alertType, required this.description, required this.riskScore});

  factory AlertCase.fromJson(Map<String, dynamic> json) => AlertCase(
    patientName: json['patient_name'],
    alertType: json['alert_type'],
    description: json['description'],
    riskScore: (json['risk_score'] ?? 0.0).toDouble(),
  );
}

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  // 🔹 Backend Data Holders
  List<Appointment> _appointments = [];
  List<AlertCase> _alerts = [];
  int _queueCount = 0;
  double _efficiency = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  /// 🔹 BACKEND-DRIVEN: Fetch data from doctor.py endpoint
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final doctorUid = prefs.getString('doctor_uid');
      
      // Ensure we have the latest token
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        user = await FirebaseAuth.instance.authStateChanges().first;
      }
      final token = user != null ? await user.getIdToken(true) : prefs.getString('token');

      final response = await dioClient.get(
        '/doctor/dashboard',
        queryParameters: {'doctor_uid': doctorUid},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _appointments = (data['appointments'] as List).map((i) => Appointment.fromJson(i)).toList();
          _alerts = (data['alerts'] as List).map((i) => AlertCase.fromJson(i)).toList();
          _queueCount = data['queue_count'] ?? 0;
          _efficiency = (data['efficiency'] ?? 0.0).toDouble();
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      debugPrint("Dashboard Error: ${e.response?.data}");
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("Dashboard Error: $e");
      setState(() => _isLoading = false);
    }
  }

  // Custom colors from UI
  static const Color secondaryFixed = Color(0xFFC2E8FF);
  static const Color onSecondaryFixed = Color(0xFF001E2B);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F3F9);
  static const Color surfaceContainerHigh = Color(0xFFE6E8ED);
  static const Color surfaceContainer = Color(0xFFECEEF3);

  @override
  Widget build(BuildContext context) {
    // 🔹 While loading, show a centered spinner within the Scaffold
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF004976)))
          : _selectedIndex == 0
          ? CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchSection(),
                  _buildMainGrid(),
                ],
              ),
            ),
          ),
        ],
        )
            : _getScreenForIndex(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildMainGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 1024;
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 8, child: _buildUpcomingAppointments()),
              const SizedBox(width: 32),
              Expanded(flex: 4, child: _buildAlertCases()),
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
    );
  }

  /// 🔹 DYNAMIC APPOINTMENTS: Maps data from backend to UI cards
  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAppointmentHeader(),
        const SizedBox(height: 32),
        if (_appointments.isEmpty)
          const Text("No appointments scheduled for today.")
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final appt = _appointments[index];
              return _appointmentCard(appt);
            },
          ),
      ],
    );
  }

  /// 🔹 DYNAMIC ALERTS: Maps AI-prioritized cases from doctor.py
  Widget _buildAlertCases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alert Cases', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF004976))),
        const SizedBox(height: 24),
        ..._alerts.map((alert) => _alertCard(alert)).toList(),
        const SizedBox(height: 16),
        _buildStatsRow(),
      ],
    );
  }

  // 🔹 REUSABLE DYNAMIC CARD WIDGETS (Preserving your UI style)
  Widget _appointmentCard(Appointment appt) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: secondaryFixed, borderRadius: BorderRadius.circular(20)),
                  child: Text(appt.time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: onSecondaryFixed))),
              const Icon(Icons.more_vert, color: Color(0xFF717881), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(appt.patientName, style: const TextStyle(fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text("${appt.type} • ${appt.reason}", style: const TextStyle(fontSize: 13, color: Color(0xFF414750))),
        ],
      ),
    );
  }

  Widget _alertCard(AlertCase alert) {
    bool isCritical = alert.riskScore > 0.8;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: isCritical ? [const Color(0xFFC2E8FF), const Color(0xFFF8F9FF)] : [surfaceContainerLow, surfaceContainerLow]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.priority_high, color: isCritical ? const Color(0xFFBA1A1A) : const Color(0xFF004976)),
              const SizedBox(width: 12),
              Expanded(child: Text(alert.patientName, style: const TextStyle(fontWeight: FontWeight.w700))),
              if (isCritical) const Icon(Icons.emergency, color: Color(0xFFBA1A1A)),
            ],
          ),
          const SizedBox(height: 12),
          Text(alert.description, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statBox('EFFICIENCY', "${(_efficiency * 100).toStringAsFixed(0)}%"),
        const SizedBox(width: 16),
        _statBox('QUEUE', _queueCount.toString()),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF004976))),
        ]),
      ),
    );
  }

  // 🔹 Helper Navigation Method
  Widget _getScreenForIndex() {
    switch (_selectedIndex) {
      case 1: return const DoctorScheduleScreen();
      case 2: return const PatientHistoryScreen();
      case 3: return const PrescriptionLogPage();
      default: return const SizedBox();
    }
  }

  // 🔹 UI Sections (Same as original, but separated for cleanliness)
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true, pinned: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      title: const Text('CliniX AI', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w800, color: Color(0xFF00629B))),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertDashboard()))),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/');
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      constraints: const BoxConstraints(maxWidth: 600),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search patients, records...',
          prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: surfaceContainerLow,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildAppointmentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Upcoming Appointments', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF004976))),
        Text('Today, ${DateFormat('MMM d').format(DateTime.now())}', style: const TextStyle(fontSize: 13, color: Color(0xFF414750))),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      selectedItemColor: const Color(0xFF004976),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Log'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Widget _buildFAB() => FloatingActionButton(heroTag: null, onPressed: () {}, backgroundColor: const Color(0xFF004976), child: const Icon(Icons.add, color: Colors.white));
}