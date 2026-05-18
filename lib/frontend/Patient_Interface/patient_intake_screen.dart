import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backend/app/models/care_path.dart'; // Ensure path is correct
import '../../core/api_client.dart';
import 'care_path_screen.dart';

class PatientIntakeScreen extends StatefulWidget {
  const PatientIntakeScreen({super.key});

  @override
  State<PatientIntakeScreen> createState() => _PatientIntakeScreenState();
}

class _PatientIntakeScreenState extends State<PatientIntakeScreen> {
  // Logic Variables
  double _severity = 7;
  int _selectedHospital = 0;
  bool _isLoading = false;
  bool _isLoadingHospitals = true;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _nameError = false;
  bool _ageError = false;
  bool _symptomError = false;

  Map<String, bool> _symptoms = {};

  // Database Data
  final List<Map<String, String>> _hospitals = [
    {'id': 'apollo_jh', 'name': 'Apollo Hospitals', 'detail': 'Jubilee Hills, Hyderabad'},
    {'id': 'kims_begumpet', 'name': 'KIMS-Sunshine Hospitals', 'detail': 'Begumpet, Hyderabad'},
    {'id': 'continental_gachibowli', 'name': 'Continental Hospitals', 'detail': 'Gachibowli, Hyderabad'},
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadSymptomsFromDatabase();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 🔹 Backend: Fetch Symptoms from Firestore
  Future<void> _loadSymptomsFromDatabase() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('common_symptoms').get();
      if (snapshot.docs.isNotEmpty) {
        final symptomsMap = <String, bool>{};
        for (var doc in snapshot.docs) {
          symptomsMap[doc.data()['name'] as String] = false;
        }
        setState(() {
          _symptoms = symptomsMap;
          _isLoadingHospitals = false;
        });
      } else {
        _useDefaultSymptoms();
      }
    } catch (e) {
      _useDefaultSymptoms();
    }
  }

  void _useDefaultSymptoms() {
    setState(() {
      _symptoms = {
        'Fever': false,
        'Dry Cough': false,
        'Fatigue': false,
        'Headache': false,
        'Sore Throat': false,
      };
      _isLoadingHospitals = false;
    });
  }

  // 🔹 Logic: Validation
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

  // 🔹 Backend: API Submission with Dio
  Future<void> _submitIntake() async {
    if (!_validate()) return;
    setState(() => _isLoading = true);

    try {
      final currentUser = _auth.currentUser;
      String? idToken;
      
      if (currentUser != null) {
        idToken = await currentUser.getIdToken();
        debugPrint("✅ Got ID Token for logged-in user");
      }

      // 🔹 MATCHES BACKEND: Construct structured data
      final Map<String, dynamic> requestData = {
        "patient_uid": currentUser?.uid,
        "full_name": _nameController.text.trim(),
        "age": int.tryParse(_ageController.text.trim()),
        "hospital_id": _hospitals[_selectedHospital]['id'],
        "symptoms": _symptoms.entries
            .where((e) => e.value)
            .map((e) => {
              "name": e.key,
              "severity": _severity.round(),
              "duration_days": 1, // Defaulting to 1 for intake
            })
            .toList(),
        "description": _descriptionController.text.trim(),
      };

      final response = await dioClient.post(
        '/patient/intake',
        options: idToken != null 
            ? Options(headers: {'Authorization': 'Bearer $idToken'})
            : null,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // 🔹 SEAMLESS LOGIN: If backend returned a token, sign in now!
        if (data['token'] != null) {
          debugPrint("🔑 Seamless Login: Signing in with custom token...");
          final userCred = await _auth.signInWithCustomToken(data['token']);
          final idToken = await userCred.user!.getIdToken();
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', idToken ?? data['token']); // Store ID Token for reference
          await prefs.setString('role', 'patient');
          debugPrint("✅ Logged in as: ${userCred.user?.uid}");
        }

        if (!mounted) return;
        try {
          final analysis = CarePathData.fromJson(data);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CarePathScreen(
                patientName: _nameController.text.trim(),
                severity: _severity.round(),
                selectedSymptoms: _symptoms.entries.where((e) => e.value).map((e) => e.key).toList(),
                analysisResult: analysis,
              ),
            ),
          );
        } catch (e) {
          debugPrint("❌ JSON Mapping Error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("JSON Mapping Error: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ API Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('CliniX AI',
            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF00629B), letterSpacing: -0.5)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(radius: 16, backgroundColor: Color(0xFFE6E8ED), child: Icon(Icons.person, size: 18, color: Colors.grey)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient Intake',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF004976), letterSpacing: -1)),
              const SizedBox(height: 6),
              const Text('Please provide accurate details to help our AI assist your clinical triage.',
                  style: TextStyle(color: Color(0xFF414750), fontSize: 14)),
              const SizedBox(height: 24),
  
              // 1. Identity Details Card
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
  
              // 2. Common Symptoms Card (Chip Style)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.medical_services_outlined, 'Common Symptoms'),
                    const SizedBox(height: 12),
                    _isLoadingHospitals
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFF004976) : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _symptomError ? Colors.red : (active ? const Color(0xFF004976) : const Color(0xFFC0C7D1)),
                                width: _symptomError ? 1.5 : 1,
                              ),
                            ),
                            child: Text(e.key, style: TextStyle(color: active ? Colors.white : const Color(0xFF414750), fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_symptomError) ...[
                      const SizedBox(height: 10),
                      const Text('Please select at least one symptom', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                    const SizedBox(height: 20),
                    const Text('Describe Illness (NLP Analysis)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF414750), fontSize: 13)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe onset and specific details. Our AI will analyze this for underlying conditions...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFFF2F3F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
  
              // 3. Severity Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFC2E8FF), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(children: [Icon(Icons.speed, color: Color(0xFF004976)), SizedBox(width: 8), Text('Severity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF004976)))]),
                        Text('${_severity.round()}/10', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF004976))),
                      ],
                    ),
                    Slider(
                      value: _severity, min: 1, max: 10,
                      activeColor: const Color(0xFF004976),
                      onChanged: (v) => setState(() => _severity = v),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mild', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF004976))),
                        Text('Moderate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF004976))),
                        Text('Severe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF004976))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
  
              // 4. Hospital Selection Card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.location_on_outlined, 'Preferred Hospital'),
                    const SizedBox(height: 16),
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
                            border: selected ? const Border(left: BorderSide(color: Color(0xFF004976), width: 4)) : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(h['name']!, style: const TextStyle(fontWeight: FontWeight.w700)), Text(h['detail']!, style: const TextStyle(fontSize: 11, color: Colors.grey))])),
                              if (selected) const Icon(Icons.check_circle, color: Color(0xFF004976)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
  
              // 5. Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitIntake,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004976),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Complete Intake', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Helper Widgets from UI 2
  Widget _buildBottomNav() => Container(
    decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(icon: Icons.home_outlined, label: 'Home', onTap: () => Navigator.popUntil(context, (r) => r.isFirst)),
            _navItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
          ],
        ),
      ),
    ),
  );

  Widget _navItem({required IconData icon, required String label, required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFF004976)), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF004976)))]),
  );

  Widget _card({required Widget child}) => Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: child
  );

  Widget _sectionHeader(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xFF004976)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18))]);

  Widget _inputField({required String label, required String hint, required TextInputType type, required TextEditingController controller, required bool hasError, required String errorText, required Function(String) onChanged}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF414750), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, keyboardType: type, onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint, filled: true,
            fillColor: hasError ? Colors.red.withOpacity(0.05) : const Color(0xFFF2F3F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: hasError ? OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red, width: 1.5)) : null,
          ),
        ),
        if (hasError) Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
      ]);
}