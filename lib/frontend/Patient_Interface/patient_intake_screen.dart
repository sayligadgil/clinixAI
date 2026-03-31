import 'package:flutter/material.dart';
import 'care_path_screen.dart';

class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({super.key});

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  double _severity = 7;
  final Map<String, bool> _symptoms = {
    'Fever': false,
    'Dry Cough': true,
    'Fatigue': false,
    'Headache': false,
    'Sore Throat': false,
    'Shortness of Breath': false,
    'Chills': false,
  };
  int _selectedHospital = 0;

  final List<Map<String, String>> _hospitals = [
    {'name': "St. Mary's General", 'detail': '2.4 miles away • 15 min wait'},
    {'name': 'Central Health Clinic', 'detail': '4.1 miles away • 5 min wait'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 1,
        leading: const BackButton(color: Color(0xFF004976)),
        title: const Text(
          'CliniX AI',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF00629B),
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE6E8ED),
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Patient Intake',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF004976),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please provide accurate details to help our AI assist your clinical triage.',
              style: TextStyle(color: Color(0xFF414750), fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Identity Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.person_outline, 'Identity Details'),
                  const SizedBox(height: 20),
                  _buildTextField('Full Name', 'John Doe', TextInputType.name),
                  const SizedBox(height: 16),
                  _buildTextField('Age', '32', TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Symptoms Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.medical_services_outlined, 'Common Symptoms'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _symptoms.entries.map((entry) {
                      final selected = entry.value;
                      return GestureDetector(
                        onTap: () => setState(() => _symptoms[entry.key] = !selected),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF004976) : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected ? const Color(0xFF004976) : const Color(0xFFC0C7D1),
                            ),
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              color: selected ? Colors.white : const Color(0xFF414750),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Describe Illness (Optional)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414750),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Mention when symptoms started and any specific details...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF2F3F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Severity Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFC2E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.speed, color: Color(0xFF004976)),
                          SizedBox(width: 8),
                          Text(
                            'Severity',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF004976),
                            ),
                          ),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${_severity.round()}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF004976),
                              ),
                            ),
                            const TextSpan(
                              text: '/10',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF004976),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbColor: const Color(0xFF004976),
                      activeTrackColor: const Color(0xFF004976),
                      inactiveTrackColor: Colors.white.withOpacity(0.6),
                      overlayColor: const Color(0xFF004976).withOpacity(0.1),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _severity,
                      min: 1,
                      max: 10,
                      onChanged: (val) => setState(() => _severity = val),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mild', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF004976), letterSpacing: 1)),
                      Text('Moderate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF004976), letterSpacing: 1)),
                      Text('Severe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF004976), letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hospital Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.location_on_outlined, 'Preferred Hospital'),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: 'Search hospital or clinic...',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF2F3F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._hospitals.asMap().entries.map((entry) {
                    final i = entry.key;
                    final h = entry.value;
                    final selected = _selectedHospital == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedHospital = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF004976).withOpacity(0.05) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? const Border(left: BorderSide(color: Color(0xFF004976), width: 4))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['name']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(h['detail']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle, color: Color(0xFF004976)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer + Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEEF3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'By continuing, our AI will prioritize your case based on the severity and symptoms provided. Emergency? Call 112.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarePathScreen(),
                    ),
                  );
                },
                icon: const Text(
                  'Complete Intake',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                label: const Icon(Icons.arrow_forward, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004976),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  elevation: 4,
                  shadowColor: const Color(0xFF004976).withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_outlined, 'Home', false),
                _navItem(Icons.calendar_month_outlined, 'Schedule', true),
                _navItem(Icons.history, 'History', false),
                _navItem(Icons.psychology_outlined, 'AI Log', false),
                _navItem(Icons.settings_outlined, 'Settings', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFC2E8FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF004976) : Colors.grey, size: 22),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF004976) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF004976), size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }

  Widget _buildTextField(String label, String hint, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF414750), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}