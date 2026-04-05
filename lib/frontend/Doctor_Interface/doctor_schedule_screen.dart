import 'package:flutter/material.dart';

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

class DoctorScheduleScreen extends StatelessWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(width: 12),
            const Text(
              'CliniX AI',
              style: TextStyle(
                color: CliniColor.primaryContainer,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: CliniColor.primary,
              ),
            ),
            const Text(
              "Monday, October 24, 2023 • 8 Appointments remaining",
              style: TextStyle(color: CliniColor.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Bento Grid - Calendar & Brief
            const CalendarSection(),
            const SizedBox(height: 24),
            const AiDailyBrief(),
            const SizedBox(height: 32),

            // Appointments List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Appointments",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: CliniColor.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("5 Items",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List of Cards
            const AppointmentCard(
              name: "Sarah Jenkins",
              time: "09:00",
              period: "AM",
              subtitle: "Chronic Hypertension Follow-up",
              icon: Icons.medical_services_outlined,
              isActive: true,
            ),
            const AppointmentCard(
              name: "Robert Chen",
              time: "10:30",
              period: "AM",
              subtitle: "Post-Op Respiratory Scan",
              icon: Icons.air_outlined,
            ),
            const AppointmentCard(
              name: "Alice Thompson",
              time: "08:15",
              period: "AM",
              subtitle: "Session Completed",
              icon: Icons.check_circle,
              isCompleted: true,
            ),
            const SizedBox(height: 100), // Spacing for BottomNav
          ],
        ),
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
  const CalendarSection({super.key});

  @override
  State<CalendarSection> createState() => _CalendarSectionState();
}

class _CalendarSectionState extends State<CalendarSection> {
  // ✅ ADD THIS HERE (STEP 2)
  int selectedIndex = 0;

  final List<Map<String, String>> dates = [
    {"day": "Mon", "date": "24"},
    {"day": "Tue", "date": "25"},
    {"day": "Wed", "date": "26"},
    {"day": "Thu", "date": "27"},
    {"day": "Fri", "date": "28"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("October 2023",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.chevron_left), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.chevron_right), onPressed: () {}),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateItem("Mon", "24", isSelected: true),
              _buildDateItem("Tue", "25"),
              _buildDateItem("Wed", "26", hasDot: true),
              _buildDateItem("Thu", "27"),
              _buildDateItem("Fri", "28", hasDot: true),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDateItem(String day, String date,
      {bool isSelected = false, bool hasDot = false}) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: 45,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? CliniColor.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
        if (hasDot)
          const Icon(Icons.circle, size: 6, color: CliniColor.primary),
      ],
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
        gradient: const LinearGradient(
          colors: [CliniColor.secondaryFixed, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: CliniColor.primary, size: 32),
          const SizedBox(height: 12),
          const Text("AI Daily Brief",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text(
              "3 patients flagged for 'Follow-up required' based on recent lab updates."),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.6),
              foregroundColor: CliniColor.primary,
              elevation: 0,
            ),
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
  final bool isSelected, isCompleted, isActive;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.time,
    required this.period,
    required this.subtitle,
    required this.icon,
    this.isSelected = false,
    this.isCompleted = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.white.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? CliniColor.primary.withOpacity(0.1)
                    : CliniColor.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(time,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? CliniColor.primary : Colors.black)),
                  Text(period, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(icon, size: 14, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
                value: isCompleted,
                onChanged: (v) {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4))),
            const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class CliniBottomNav extends StatelessWidget {
  const CliniBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Home"),
          _navItem(Icons.calendar_month, "Schedule", isActive: true),
          _navItem(Icons.history, "History"),
          _navItem(Icons.psychology_outlined, "AI Log"),
          _navItem(Icons.settings_outlined, "Settings"),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? CliniColor.primary : Colors.grey),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isActive ? CliniColor.primary : Colors.grey)),
      ],
    );
  }
}
