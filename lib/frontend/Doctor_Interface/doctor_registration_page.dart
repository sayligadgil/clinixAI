import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import 'doctor_dashboard.dart';

class PractitionerRegistrationPage extends StatefulWidget {
  const PractitionerRegistrationPage({Key? key}) : super(key: key);

  @override
  State<PractitionerRegistrationPage> createState() =>
      _PractitionerRegistrationPageState();
}

class _PractitionerRegistrationPageState
    extends State<PractitionerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers mapped to Backend Schema
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController(); // 🔹 Added for Backend Schema
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedSpecialization = 'General Practice';
  String? _selectedHospitalId; // 🔹 To store h001, h002, etc.

  bool _isLoading = false;
  List<Map<String, dynamic>> _hospitals = [];

  // 🔹 Backend Configuration
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 🔹 DATABASE-DRIVEN: Load Apollo, KIMS, Continental from Firestore
  Future<void> _loadHospitals() async {
    try {
      final snapshot = await _firestore.collection('hospitals').get();
      setState(() {
        _hospitals = snapshot.docs.map((doc) => {
          'id': doc.id,
          'name': doc.data()['name'],
        }).toList();
        if (_hospitals.isNotEmpty) _selectedHospitalId = _hospitals[0]['id'];
      });
    } catch (e) {
      debugPrint("Error loading hospitals: $e");
    }
  }

  /// 🔹 BACKEND-DRIVEN: Submit to FastAPI /auth/register/doctor
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await dioClient.post(
        '/auth/register/doctor',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'full_name': _fullNameController.text.trim(),
          'medical_license': _licenseController.text.trim(),
          'hospital_id': _selectedHospitalId,
          'specialization': _selectedSpecialization,
          'phone': _phoneController.text.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // 🔹 SEAMLESS LOGIN: Exchange custom token for ID token
        final customToken = data['token'] as String;
        final userCredential = await FirebaseAuth.instance.signInWithCustomToken(customToken);
        final idToken = await userCredential.user!.getIdToken();

        // 🔹 Save session data for the dashboard
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', idToken!);
        await prefs.setString('doctor_uid', data['uid']);
        await prefs.setString('hospital_id', data['hospital_id'] ?? '');
        await prefs.setString('role', data['role'] ?? 'doctor');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Practitioner Account Created Successfully')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorDashboard()),
        );
      }
    } on DioException catch (e) {
      String error = "Registration failed.";
      if (e.response?.data != null && e.response?.data['detail'] != null) {
        var detail = e.response?.data['detail'];
        if (detail is String) {
          error = detail;
        } else if (detail is List && detail.isNotEmpty) {
          error = detail[0]['msg']?.toString() ?? detail.toString();
        } else {
          error = detail.toString();
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white.withOpacity(0.8),
                title: Text('CliniX AI', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 120, left: 16, right: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return constraints.maxWidth >= 1024
                          ? _buildTwoColumnLayout(context)
                          : _buildSingleColumnLayout(context);
                    },
                  ),
                ),
              ),
            ],
            ),
            if (_isLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  // UI layout methods remain the same to preserve your exact design
  Widget _buildTwoColumnLayout(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 5, child: _buildHeroSection(context)),
      const SizedBox(width: 48),
      Expanded(flex: 7, child: _buildRegistrationForm(context)),
    ],
  );

  Widget _buildSingleColumnLayout(BuildContext context) => Column(
    children: [_buildHeroSection(context), const SizedBox(height: 48), _buildRegistrationForm(context)],
  );

  // 🔹 UI Helper: Form logic updated with database values
  Widget _buildRegistrationForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(context, '01', 'Personal Details'),
            const SizedBox(height: 24),
            _buildTextField(context, label: 'Full Name', placeholder: 'Dr. Julian Sterling', controller: _fullNameController),
            const SizedBox(height: 24),
            _buildTextField(context, label: 'Phone Number', placeholder: '+91 98XXX XXXXX', controller: _phoneController, keyboardType: TextInputType.phone),

            const SizedBox(height: 40),
            _buildSectionHeader(context, '02', 'Professional Credentials'),
            const SizedBox(height: 24),

            // 🔹 DATABASE-DRIVEN: Hospital Dropdown
            _buildHospitalDropdown(context),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildDropdownField(context, label: 'Specialization', value: _selectedSpecialization, items: ['Cardiology', 'Dermatology', 'Emergency Medicine', 'Endocrinology', 'ENT', 'Gastroenterology', 'General Practice', 'General Surgery', 'Gynaecology', 'Haematology', 'Infectious Disease', 'Nephrology', 'Neurology', 'Neurosurgery', 'Obstetrics', 'Oncology', 'Ophthalmology', 'Orthopaedics', 'Paediatric Cardiology', 'Paediatrics', 'Psychiatry', 'Pulmonology', 'Radiology'], onChanged: (v) => setState(() => _selectedSpecialization = v!))),
                const SizedBox(width: 24),
                Expanded(child: _buildTextField(context, label: 'Medical License', placeholder: 'LIC-99827-BC', controller: _licenseController)),
              ],
            ),

            const SizedBox(height: 40),
            _buildSectionHeader(context, '03', 'Account Security'),
            const SizedBox(height: 24),
            _buildTextField(context, label: 'Email Address', placeholder: 'j.sterling@hospital.org', controller: _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField(context, label: 'Password', placeholder: '••••••••', controller: _passwordController, obscureText: true)),
                const SizedBox(width: 24),
                Expanded(child: _buildTextField(context, label: 'Confirm', placeholder: '••••••••', controller: _confirmPasswordController, obscureText: true,
                    validator: (v) => v != _passwordController.text ? 'Passwords match error' : null)),
              ],
            ),
            const SizedBox(height: 48),

            // Submit Button
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(left: 4, bottom: 8), child: Text('Hospital Affiliation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        Container(
          height: 56, padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: const Color(0xFFF2F3F9), borderRadius: BorderRadius.circular(12)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedHospitalId,
              isExpanded: true,
              items: _hospitals.map((h) => DropdownMenuItem(value: h['id'] as String, child: Text(h['name']))).toList(),
              onChanged: (v) => setState(() => _selectedHospitalId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegistration,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer]),
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Center(child: Text('Create Practitioner Account', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      ),
    );
  }

  // 🔹 Inherited UI Helpers (Headers, TextFields, Nav items) remain identical to original...
  Widget _buildSectionHeader(BuildContext context, String number, String title) => Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFF2F3F9), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold)))), const SizedBox(width: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))]);

  Widget _buildTextField(BuildContext context, {required String label, required String placeholder, required TextEditingController controller, bool obscureText = false, TextInputType? keyboardType, String? Function(String?)? validator}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))), Container(height: 56, decoration: BoxDecoration(color: const Color(0xFFF2F3F9), borderRadius: BorderRadius.circular(12)), child: TextFormField(controller: controller, obscureText: obscureText, keyboardType: keyboardType, validator: validator ?? (v) => v!.isEmpty ? 'Required' : null, decoration: InputDecoration(hintText: placeholder, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16))))]);

  Widget _buildDropdownField(BuildContext context, {required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))), Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: const Color(0xFFF2F3F9), borderRadius: BorderRadius.circular(12)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: onChanged)))]);

  Widget _buildHeroSection(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFC2E8FF), borderRadius: BorderRadius.circular(9999)), child: const Text('PRACTITIONER PORTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5))), const SizedBox(height: 16), RichText(text: TextSpan(style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w800, fontSize: 40, color: Theme.of(context).colorScheme.primary, height: 1.2), children: [const TextSpan(text: 'Empowering Healthcare with '), TextSpan(text: 'AI Precision', style: TextStyle(color: Theme.of(context).colorScheme.secondary)), const TextSpan(text: '.')])), const SizedBox(height: 16), const Text('Join an elite network of medical professionals leveraging advanced diagnostics.', style: TextStyle(fontSize: 18, height: 1.6))]);
}