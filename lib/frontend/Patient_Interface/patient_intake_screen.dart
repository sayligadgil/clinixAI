import 'package:flutter/material.dart';
import 'care_path_screen.dart';

class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({super.key});

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  double _severity = 7;
  int _selectedHospital = 0;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _nameError = false;
  bool _ageError = false;
  bool _symptomError = false;

  final Map<String, bool> _symptoms = {
    'Fever': false,
    'Dry Cough': false,
    'Fatigue': false,
    'Headache': false,
    'Sore Throat': false,
    'Shortness of Breath': false,
    'Chills': false,
  };

  final List<Map<String, String>> _hospitals = [
    {'name': "St. Mary's General", 'detail': '2.4 miles away • 15 min wait'},
    {'name': 'Central Health Clinic', 'detail': '4.1 miles away • 5 min wait'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validate() {
    final nameEmpty = _nameController.text.trim().isEmpty;
    final ageEmpty = _ageController.text.trim().isEmpty;
    final noSymptom = !_symptoms.values.contains(true);
    setState(() {
      _nameError = nameEmpty;
      _ageError = ageEmpty;
      _symptomError = noSymptom;
    });
    return !nameEmpty && !ageEmpty && !noSymptom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.person_outline, 'Identity Details'),
                  const SizedBox(height: 20),
                  _inputField(
                    label: 'Full Name',
                    hint: 'John Doe',
                    type: TextInputType.name,
                    controller: _nameController,
                    hasError: _nameError,
                    errorText: 'Full name is required',
                    onChanged: (_) => setState(() => _nameError = false),
                  ),
                  const SizedBox(height: 16),
                  _inputField(
                    label: 'Age',
                    hint: '32',
                    type: TextInputType.number,
                    controller: _ageController,
                    hasError: _ageError,
                    errorText: 'Age is required',
                    onChanged: (_) => setState(() => _ageError = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Symptoms Card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(Icons.medical_services_outlined, 'Common Symptoms'),
                  const SizedBox(height: 4),
                  const Text(
                    'Select at least one symptom *',
                    style: TextStyle(fontSize: 12, color: Color(0xFF414750)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _symptoms.entries.map((e) {
                      final active = e.value;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _symptoms[e.key] = !active;
                          _symptomError = false;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? const Color(0xFF004976) : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _symptomError
                                  ? Colors.red
                                  : active
                                  ? const Color(0xFF004976)
                                  : const Color(0xFFC0C7D1),
                              width: _symptomError ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            e.key,
                            style: TextStyle(
                              color: active ? Colors.white : const Color(0xFF414750),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_symptomError) ...[
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Please select at least one symptom',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
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
                      const Row(
                        children: [
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
                  const SizedBox(height: 12),
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
                      onChanged: (v) => setState(() => _severity = v),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mild',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF004976),
                              letterSpacing: 1)),
                      Text('Moderate',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF004976),
                              letterSpacing: 1)),
                      Text('Severe',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF004976),
                              letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Hospital Card
            _card(
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
                          color: selected
                              ? const Color(0xFF004976).withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? const Border(
                              left: BorderSide(color: Color(0xFF004976), width: 4))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h['name']!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text(h['detail']!,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
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

            // Disclaimer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E8ED),
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

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarePathScreen(
                          patientName: _nameController.text.trim(),
                          severity: _severity.round(),
                          selectedSymptoms: _symptoms.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList(),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004976),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                  elevation: 4,
                  shadowColor: const Color(0xFF004976).withOpacity(0.3),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Complete Intake',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                ),
                _navItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ],
    ),
    child: child,
  );

  Widget _sectionHeader(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: const Color(0xFF004976), size: 22),
      const SizedBox(width: 8),
      Text(title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
    ],
  );

  Widget _inputField({
    required String label,
    required String hint,
    required TextInputType type,
    required TextEditingController controller,
    required bool hasError,
    required String errorText,
    required Function(String) onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF414750),
                fontSize: 13,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              filled: true,
              fillColor: hasError
                  ? Colors.red.withOpacity(0.05)
                  : const Color(0xFFF2F3F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: hasError
                    ? const BorderSide(color: Colors.red, width: 1.5)
                    : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : const Color(0xFF004976),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: hasError
                  ? const Icon(Icons.error_outline, color: Colors.red, size: 20)
                  : null,
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 14),
                const SizedBox(width: 6),
                Text(errorText,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ),
          ],
        ],
      );

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF004976), size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF004976))),
          ],
        ),
      );
}