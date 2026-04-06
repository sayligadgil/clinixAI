import 'package:flutter/material.dart';
import 'doctor_notifs.dart';

// REUSING THE COLORS FROM PREVIOUS SCREEN FOR CONSISTENCY
class CliniColor {
  static const primary = Color(0xFF004976);
  static const primaryContainer = Color(0xFF00629B);
  static const primaryFixed = Color(0xFFCEE5FF);
  static const onPrimaryFixed = Color(0xFF001D33);
  static const secondary = Color(0xFF006688);
  static const secondaryFixed = Color(0xFFC2E8FF);
  static const secondaryFixedDim = Color(0xFF75D1FF);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainerLow = Color(0xFFF2F3F9);
  static const surfaceContainerHigh = Color(0xFFE6E8ED);
  static const surfaceContainerHighest = Color(0xFFE1E2E8);
  static const onSurface = Color(0xFF191C20);
  static const onSurfaceVariant = Color(0xFF414750);
  static const tertiaryFixed = Color(0xFFE0E0FF);
  static const onTertiaryFixed = Color(0xFF000767);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

class PatientHistoryScreen extends StatelessWidget {
  const PatientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CliniColor.surface,
      body: CustomScrollView(
        slivers: [
          // Glass-effect TopAppBar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDjpEhrsXlgppa7UK-nfFlkNa-A52y1oNsOgE3yBnxX2dEwamV-k5rpFRn4pVDqOkLyPU8P_PMRQElOySLYSekWCRdRa8J2__miSD75ubC6K5Boop4Hf1Hvx7Mof-LX-BYdzhJKW-ucpzSTZMRUmK66orr6LtfUn0D3UdjkEQIJWhcWbtCjfuih0xN3JUQwaromkSGkXMy1Z4osAkN-g1xETfU-sOqLBFBXO8cn3lic9EKA0-tU5G1kmZZsIvAdT5i8j8ItS-NnNQ4'),
                ),
                const SizedBox(width: 12),
                const Text(
                  'CliniX AI',
                  style: TextStyle(
                    color: CliniColor.primaryContainer,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: CliniColor.primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlertDashboard(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                const Text(
                  'Patient Records',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CliniColor.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or disease...',
                    hintStyle: TextStyle(
                        color: CliniColor.onSurfaceVariant.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search,
                        color: CliniColor.onSurfaceVariant),
                    filled: true,
                    fillColor: CliniColor.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips Row
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All Records', isActive: true),
                      _buildFilterChip('AI-Predicted'),
                      _buildFilterChip('Doctor-Attended'),
                      _buildFilterChip('Urgent'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Records List
                const RecordEntry(
                  initials: 'EH',
                  name: 'Elena Hernandez',
                  id: '#PX-9921',
                  category: 'Cardiology',
                  date: 'Oct 24, 2023',
                  isAiPredicted: true,
                  avatarColor: CliniColor.primaryFixed,
                  textColor: CliniColor.onPrimaryFixed,
                ),
                const RecordEntry(
                  initials: 'MB',
                  name: 'Marcus Bennett',
                  id: '#PX-8104',
                  category: 'Neurology',
                  date: 'Oct 22, 2023',
                  isAiPredicted: false,
                  avatarColor: CliniColor.tertiaryFixed,
                  textColor: CliniColor.onTertiaryFixed,
                ),
                const RecordEntry(
                  initials: 'SW',
                  name: 'Sarah Williams',
                  id: '#PX-7742',
                  category: 'Dermatology',
                  date: 'Oct 21, 2023',
                  isAiPredicted: true,
                  avatarColor: CliniColor.secondaryFixed,
                  textColor: CliniColor.onSurface,
                ),
                const RecordEntry(
                  initials: 'JL',
                  name: 'James Liu',
                  id: '#PX-1029',
                  category: 'Oncology',
                  date: 'Oct 20, 2023',
                  isAiPredicted: false,
                  avatarColor: CliniColor.errorContainer,
                  textColor: CliniColor.onErrorContainer,
                ),

                // AI Insight Card
                const SizedBox(height: 24),
                const AiInsightCard(),

                const SizedBox(height: 100), // Padding for BottomNav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? CliniColor.primary : CliniColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : CliniColor.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class RecordEntry extends StatelessWidget {
  final String initials, name, id, category, date;
  final bool isAiPredicted;
  final Color avatarColor, textColor;

  const RecordEntry({
    super.key,
    required this.initials,
    required this.name,
    required this.id,
    required this.category,
    required this.date,
    required this.isAiPredicted,
    required this.avatarColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(id,
                    style: const TextStyle(
                        color: CliniColor.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAiPredicted
                      ? CliniColor.secondaryFixed.withOpacity(0.3)
                      : CliniColor.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: isAiPredicted
                      ? Border.all(color: CliniColor.secondary.withOpacity(0.1))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAiPredicted
                          ? Icons.psychology
                          : Icons.medical_services_outlined,
                      size: 14,
                      color: isAiPredicted
                          ? CliniColor.secondary
                          : CliniColor.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAiPredicted ? 'AI-Predicted' : 'Doctor-Attended',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isAiPredicted
                            ? CliniColor.secondary
                            : CliniColor.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(date,
                  style: const TextStyle(
                      fontSize: 11, color: CliniColor.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CliniColor.secondaryFixed, CliniColor.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CliniColor.secondary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome, color: CliniColor.secondary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Database Insight',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "We've noticed a 15% increase in Cardiology scans this month. CliniAI has pre-sorted these records for your review.",
                  style: TextStyle(
                      fontSize: 13,
                      color: CliniColor.onSurfaceVariant,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
