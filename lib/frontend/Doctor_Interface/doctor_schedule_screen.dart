import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_notifs.dart';

// --- Data Models ---

class Appointment {
  final String id;
  final String patientName;
  final DateTime dateTime;
  final String reason;
  final IconData categoryIcon;
  bool isCompleted;

  Appointment({
    required this.id,
    required this.patientName,
    required this.dateTime,
    required this.reason,
    required this.categoryIcon,
    this.isCompleted = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      patientName: json['patient_name'] ?? 'Unknown Patient',
      dateTime: DateTime.parse(json['appointment_time']),
      reason: json['reason'] ?? '',
      categoryIcon: _getIconForCategory(json['category']),
      isCompleted: json['status'] == 'completed',
    );
  }

  static IconData _getIconForCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'respiratory': return Icons.air_outlined;
      case 'cardiology': return Icons.favorite_outline;
      default: return Icons.medical_services_outlined;
    }
  }
}

class CliniColor {
  static const primary = Color(0xFF004976);
  static const primaryContainer = Color(0xFF00629B);
  static const secondary = Color(0xFF006688);
  static const secondaryFixed = Color(0xFFC2E8FF);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainerLow = Color(0xFFF2F3F9);
  static const surfaceContainerHighest = Color(0xFFE1E2E8);
  static const onSurface = Color(0xFF191C20);
  static const onSurfaceVariant = Color(0xFF414750);
}

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});
  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  late Future<List<Appointment>> _appointmentsFuture;
  DateTime _selectedDate = DateTime.now();

  // Backend Config
  final String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  String token = "YOUR_BEARER_TOKEN";

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = Future.value([]);
    _loadTokenAndAppointments();
  }

  Future<void> _loadTokenAndAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "YOUR_BEARER_TOKEN";
      _appointmentsFuture = fetchAppointments(_selectedDate);
    });
  }

  Future<List<Appointment>> fetchAppointments(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/schedule?date=$formattedDate'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Appointment.fromJson(json)).toList();
      } else {
        // Fallback or throw error
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      throw Exception('Backend connection error: $e');
    }
  }

  Future<void> _toggleStatus(Appointment appt, bool? value) async {
    // Optimistic UI update
    setState(() { appt.isCompleted = value ?? false; });

    // Backend update
    await http.patch(
      Uri.parse('$baseUrl/doctor/appointments/${appt.id}'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode({'status': (value ?? false) ? 'completed' : 'pending'}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CliniColor.surface,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(radius: 20, backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/...')),
            const SizedBox(width: 12),
            const Text('CliniX AI', style: TextStyle(color: CliniColor.primaryContainer, fontWeight: FontWeight.w900, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertDashboard())),
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          final appointments = snapshot.data ?? [];
          final remainingCount = appointments.where((a) => !a.isCompleted).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSameDay(_selectedDate, DateTime.now()) ? "Today's Schedule" : "Schedule for ${DateFormat('MMM dd').format(_selectedDate)}",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: CliniColor.primary),
                ),
                Text(
                  "${DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate)} • $remainingCount Appointments remaining",
                  style: const TextStyle(color: CliniColor.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                CalendarSection(
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _appointmentsFuture = fetchAppointments(date);
                    });
                  },
                ),
                const SizedBox(height: 24),
                const AiDailyBrief(),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Appointments", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: CliniColor.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
                      child: Text("${appointments.length} Items", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  const Center(child: Text("Error syncing with database"))
                else if (appointments.isEmpty)
                    const Center(child: Text("No appointments scheduled for this day."))
                  else
                    ...appointments.map((appt) => AppointmentCard(
                      name: appt.patientName,
                      time: DateFormat('hh:mm').format(appt.dateTime),
                      period: DateFormat('a').format(appt.dateTime),
                      subtitle: appt.reason,
                      icon: appt.categoryIcon,
                      isActive: !appt.isCompleted && isSameDay(appt.dateTime, DateTime.now()),
                      isCompleted: appt.isCompleted,
                      onChanged: (val) => _toggleStatus(appt, val),
                    )),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: CliniColor.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- Component Widgets ---

class CalendarSection extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  const CalendarSection({super.key, required this.onDateSelected});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  List<DateTime?> _getMonthDays(DateTime focusedDay) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);
    final weekdayOfFirst = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final paddingCount = weekdayOfFirst - 1;
    final daysCount = DateTime(focusedDay.year, focusedDay.month + 1, 0).day;

    List<DateTime?> list = [];
    for (int i = 0; i < paddingCount; i++) {
      list.add(null);
    }
    for (int i = 1; i <= daysCount; i++) {
      list.add(DateTime(focusedDay.year, focusedDay.month, i));
    }
    return list;
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getMonthDays(_focusedDay);
    final currentYear = DateTime.now().year;
    final List<int> years = List.generate(21, (index) => currentYear - 10 + index);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Header Row with Dropdowns and Chevrons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Chevron Left
              IconButton(
                icon: const Icon(Icons.chevron_left, color: CliniColor.primary),
                onPressed: _previousMonth,
              ),
              // Dropdowns for Month and Year
              Row(
                children: [
                  // Month Dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _focusedDay.month,
                      icon: const Icon(Icons.arrow_drop_down, color: CliniColor.primary),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CliniColor.primary),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _focusedDay = DateTime(_focusedDay.year, newValue, 1);
                          });
                        }
                      },
                      items: List.generate(12, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(_months[index]),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Year Dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _focusedDay.year,
                      icon: const Icon(Icons.arrow_drop_down, color: CliniColor.primary),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CliniColor.primary),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _focusedDay = DateTime(newValue, _focusedDay.month, 1);
                          });
                        }
                      },
                      items: years.map((year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              // Chevron Right
              IconButton(
                icon: const Icon(Icons.chevron_right, color: CliniColor.primary),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Weekdays Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Expanded(child: Center(child: Text("M", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
              Expanded(child: Center(child: Text("T", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
              Expanded(child: Center(child: Text("W", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
              Expanded(child: Center(child: Text("T", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
              Expanded(child: Center(child: Text("F", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
              Expanded(child: Center(child: Text("S", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
              Expanded(child: Center(child: Text("S", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)))),
            ],
          ),
          const SizedBox(height: 10),
          // Grid View of Month Days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) {
                return const SizedBox();
              }
              final isSelected = isSameDay(_selectedDay, day);
              final isToday = isSameDay(DateTime.now(), day);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                  });
                  widget.onDateSelected(day);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CliniColor.primary
                        : (isToday ? CliniColor.secondaryFixed.withOpacity(0.4) : Colors.transparent),
                    borderRadius: BorderRadius.circular(12),
                    border: isToday && !isSelected
                        ? Border.all(color: CliniColor.primary, width: 1)
                        : null,
                  ),
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? CliniColor.primary : Colors.black),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AiDailyBrief extends StatelessWidget {
  const AiDailyBrief({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [CliniColor.secondaryFixed, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: CliniColor.primary, size: 32),
          const SizedBox(height: 12),
          const Text("AI Daily Brief", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text("3 patients flagged for 'Follow-up required' based on recent lab updates."),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.6), foregroundColor: CliniColor.primary, elevation: 0),
            child: const Text("Review Insights"),
          )
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final String name, time, period, subtitle;
  final IconData icon;
  final bool isCompleted, isActive;
  final ValueChanged<bool?>? onChanged;

  const AppointmentCard({
    super.key, required this.name, required this.time, required this.period,
    required this.subtitle, required this.icon, this.isCompleted = false,
    this.isActive = false, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isCompleted ? Colors.white.withOpacity(0.4) : Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isActive ? CliniColor.primary.withOpacity(0.1) : CliniColor.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? CliniColor.primary : Colors.black)),
                  Text(period, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(icon, size: 14, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(value: isCompleted, onChanged: onChanged, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}