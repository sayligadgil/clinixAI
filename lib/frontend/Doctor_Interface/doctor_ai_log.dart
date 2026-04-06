import 'package:flutter/material.dart';

void main() => runApp(const ClinixPrescriptionApp());

class ClinixPrescriptionApp extends StatelessWidget {
  const ClinixPrescriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF004976),
          secondary: Color(0xFF006688),
          surface: Color(0xFFF8F9FF),
          onSurface: Color(0xFF191C20),
          primaryContainer: Color(0xFF004976), // Custom map for stats
          secondaryContainer: Color(0xFFC2E8FF),
          error: Color(0xFFBA1A1A),
        ),
      ),
      home: const PrescriptionLogPage(),
    );
  }
}

class PrescriptionLogPage extends StatelessWidget {
  const PrescriptionLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCEE5FF), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBgtWCpaRVoMzfpGp3-wAVVgHIvBriIfCSQAaPoq1zwRcQ-J399K4ttqJZaoiC_X8-ZKJxrIZPC58Lr2FLKZdanj11QrCDpjBajdBlw57WH2KhcGjk6vqunRZ-yQNpdx9JK0FR0jL54kUcypdYbiyhncvoFkTkojoZ7MVH3beex3F_KNmT7MTtYfdz-qQveThlPwmMXV49-SXxq6SRK5VbXZiiPM9kh_GmXC1tY9mwLkXX_P9YmSUnlyLj1SJy3TxJxsCw893ZE1m4'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'CliniX AI',
              style: TextStyle(
                color: Color(0xFF00629B),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editorial Header
            const Text(
              'AI Prescription Log',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004976)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review and validate AI-generated treatment plans. Monitor confidence scores and ensure patient safety.',
              style: TextStyle(color: Color(0xFF414750), height: 1.5),
            ),
            const SizedBox(height: 32),

            // Stats Bento Grid
            LayoutBuilder(builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMobile ? 1 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 2.5 : 1.5,
                children: const [
                  StatCard(
                    color: Color(0xFF004976),
                    icon: Icons.pending_actions,
                    label: 'PENDING',
                    value: '24',
                    subValue: 'Prescriptions for review',
                    textColor: Colors.white,
                  ),
                  StatCard(
                    color: Color(0xFFC2E8FF),
                    icon: Icons.verified,
                    label: 'SUCCESS RATE',
                    value: '94.2%',
                    subValue: 'Average AI Confidence',
                    textColor: Color(0xFF001E2B),
                  ),
                  ReviewSpeedCard(),
                ],
              );
            }),

            const SizedBox(height: 32),

            // Filter Chips
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Filter by Confidence:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ChoiceChip(
                    label: Text('High (>90%)'),
                    selected: true,
                    selectedColor: Color(0xFF004976),
                    labelStyle: TextStyle(color: Colors.white)),
                ChoiceChip(label: Text('Medium (70-90%)'), selected: false),
                ChoiceChip(label: Text('Low (<70%)'), selected: false),
              ],
            ),

            const SizedBox(height: 24),

            // Prescription Entries
            const PrescriptionCard(
              initials: 'JD',
              name: 'Johnathan Doe',
              id: '#CL-8821',
              disease: 'Hypertension Stage 2',
              desc: 'Slight cardiac enlargement detected',
              meds: ['Lisinopril 10mg', 'Amlodipine 5mg'],
              confidence: 0.98,
              accentColor: Color(0xFF004976),
            ),
            const PrescriptionCard(
              initials: 'SM',
              name: 'Sarah Miller',
              id: '#CL-9012',
              disease: 'Type 2 Diabetes Mellitus',
              desc: 'Hyperglycemic trend across last 3 labs',
              meds: ['Metformin 500mg', 'Dietary Plan A'],
              confidence: 0.92,
              accentColor: Color(0xFF006688),
              isLight: true,
            ),
            const PrescriptionCard(
              initials: 'RA',
              name: 'Robert Adams',
              id: '#CL-1143',
              disease: 'Acute Bronchitis vs Asthma',
              desc: 'Conflicting symptomatic data points',
              meds: ['Albuterol Inhaler', 'Prednisone 5mg'],
              confidence: 0.64,
              accentColor: Color(0xFFBA1A1A),
              isWarning: true,
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('Load History Log',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 80), // Spacer for nav bar
          ],
        ),
      ),
    );
  }
}

// --- Sub-Widgets ---

class StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label, value, subValue;
  final Color textColor;

  const StatCard(
      {super.key,
      required this.color,
      required this.icon,
      required this.label,
      required this.value,
      required this.subValue,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: textColor.withOpacity(0.6)),
              Text(label,
                  style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
            ],
          ),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(subValue,
              style:
                  TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

class ReviewSpeedCard extends StatelessWidget {
  const ReviewSpeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFECEEF3),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('REVIEW SPEED',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                Text('12 min avg',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
          Container(width: 1, color: Colors.grey.withOpacity(0.3), height: 40),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('TODAY',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                Text('156 checked',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004976))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrescriptionCard extends StatelessWidget {
  final String initials, name, id, disease, desc;
  final List<String> meds;
  final double confidence;
  final Color accentColor;
  final bool isLight, isWarning;

  const PrescriptionCard({
    super.key,
    required this.initials,
    required this.name,
    required this.id,
    required this.disease,
    required this.desc,
    required this.meds,
    required this.confidence,
    required this.accentColor,
    this.isLight = false,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0xFFCEE5FF).withOpacity(0.3)
            : const Color(0xFFF2F3F9),
        borderRadius: BorderRadius.circular(20),
        border: Border(
            left: BorderSide(
                color: accentColor.withOpacity(isWarning ? 0.5 : 1), width: 4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: isWarning
                    ? const Color(0xFFFFDAD6)
                    : const Color(0xFFCEE5FF),
                child: Text(initials,
                    style: TextStyle(
                        color: accentColor, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Patient ID: $id',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('CONFIDENCE',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  Row(
                    children: [
                      Text('${(confidence * 100).toInt()}%',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: accentColor)),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 50,
                        child: LinearProgressIndicator(
                            value: confidence,
                            backgroundColor: Colors.white,
                            color: accentColor,
                            minHeight: 6),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const Divider(height: 32, color: Colors.white),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isWarning)
                          const Icon(Icons.warning,
                              size: 14, color: Colors.red),
                        if (isWarning) const SizedBox(width: 4),
                        Text('PREDICTED DISEASE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentColor)),
                      ],
                    ),
                    Text(disease,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(desc,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.blueGrey)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI PRESCRIPTION',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: meds
                          .map((m) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.grey.shade300)),
                                child: Text(m,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.15),
                  foregroundColor: accentColor,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Review',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
