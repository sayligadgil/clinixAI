import 'package:flutter/material.dart';

void main() {
  runApp(const ClinixApp());
}

class ClinixApp extends StatelessWidget {
  const ClinixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter', // Assuming Inter is added to pubspec.yaml
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004976),
          primary: const Color(0xFF004976),
          secondary: const Color(0xFF006688),
          surface: const Color(0xFFF8F9FF),
          error: const Color(0xFFBA1A1A),
          onSurface: const Color(0xFF191C20),
          errorContainer: const Color(0xFFFFDAD6),
          onErrorContainer: const Color(0xFF93000A),
        ),
      ),
      home: const AlertDashboard(),
    );
  }
}

class AlertDashboard extends StatelessWidget {
  const AlertDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFCEE5FF),
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBB4f8v_RW8BZojSCSEwgiA04kxmsLA4h_H6qK0CRDn1zt-TEboQFmfzAY9zF17TOCm32uHm1W2OYHk8jJnKuAC9sBvMq2YJgnucQX0Vr3tgPH4otHuapEoFrUolb0wvL7kfXri74ZvPCuTZhX7so668ZZE0EUBC1e-raOlfE0WxhufmjkDs0C1Gxa4NPJh9Ir6xQSeneH61p-Etg2bffK6TdAqhf3gobAtA2IWuAHTI3JwWYSPtQ94hK5ZOHThm-_b-XcUdf1uUJ0'),
            ),
            const SizedBox(width: 12),
            Text(
              'CliniX AI Alerts',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF004976)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urgent Referrals',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF191C20),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded, size: 14, color: Color(0xFF93000A)),
                  SizedBox(width: 6),
                  Text(
                    '3 HIGH PRIORITY CASES DETECTED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF93000A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Alert Cards
            const AlertCard(
              name: 'Elena Rodriguez',
              time: 'Received 4 mins ago',
              confidence: '32%',
              requiresVerification: true,
              symptoms: ['Severe Chest Pain', 'Shortness of Breath', 'Nausea'],
              assessment: 'Symptoms align with Acute Coronary Syndrome. Anomaly detected in heart rate variability; AI requires clinician input.',
              urgencyColor: Color(0xFFBA1A1A),
            ),
            const SizedBox(height: 24),
            const AlertCard(
              name: 'Marcus Thorne',
              time: 'Received 12 mins ago',
              confidence: '45%',
              requiresVerification: false,
              symptoms: ['Unusual Fatigue', 'Sudden Weight Loss', 'Polydipsia'],
              assessment: 'Data points suggest onset of Type 1 Diabetes. Referral generated due to rapid symptom progression.',
              urgencyColor: Color(0xFFF97316),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF004976),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // History selected
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), label: 'AI Log'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final String name;
  final String time;
  final String confidence;
  final bool requiresVerification;
  final List<String> symptoms;
  final String assessment;
  final Color urgencyColor;

  const AlertCard({
    super.key,
    required this.name,
    required this.time,
    required this.confidence,
    required this.requiresVerification,
    required this.symptoms,
    required this.assessment,
    required this.urgencyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 6,
              child: Container(color: urgencyColor),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDAD6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Confidence: $confidence',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF93000A)),
                            ),
                          ),
                          if (requiresVerification)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text('Requires Manual Verification', style: TextStyle(fontSize: 9, fontStyle: FontStyle.italic, color: Colors.grey)),
                            ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: symptoms.map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 11, color: Color(0xFF006688))),
                      backgroundColor: const Color(0xFFECEEF3),
                      padding: EdgeInsets.zero,
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFC2E8FF), Color(0xFFF2F3F9)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology, size: 16, color: Color(0xFF004976)),
                            SizedBox(width: 8),
                            Text('AI ASSESSMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(assessment, style: const TextStyle(fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004976),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('View Case'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFE6E8ED)),
                          ),
                          child: const Text('Mark Attended'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}