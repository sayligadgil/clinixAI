import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import 'doctor_registration_page.dart';
import 'doctor_dashboard.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // 🔹 Controllers map to the 'email' and 'password' expected by auth.py
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // 🔹 Backend Configuration
  // Use localhost for Web/Desktop and 192.168.1.7 for Local Devices

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 🔹 BACKEND-DRIVEN: Handles Authentication with FastAPI
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 🔹 Call the POST /auth/login endpoint
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data; // This is the AuthResponse schema

        // 🔹 Exchange the custom token for a real Firebase ID Token so that
        // subsequent API calls (which call verify_id_token on the backend)
        // receive the correct credential type.
        final customToken = data['token'] as String;
        final userCredential = await FirebaseAuth.instance
            .signInWithCustomToken(customToken);
        final idToken = await userCredential.user!.getIdToken();

        // 🔹 Save the ID Token (not the custom token) for authenticated requests
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', idToken!);
        await prefs.setString('doctor_uid', data['uid']);
        await prefs.setString('hospital_id', data['hospital_id'] ?? '');
        await prefs.setString('role', data['role']);

        if (!mounted) return;

        // Navigate to Dashboard upon successful verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DoctorDashboard()),
        );
      }
    } on DioException catch (e) {
      String error = "Login failed. Check credentials.";
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background Blobs (Same as UI)
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.1,
            child: Container(
                width: 500, height: 500,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFFC2E8FF).withOpacity(0.3), const Color(0xFFC2E8FF).withOpacity(0)]))),
          ),
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 24 : 48, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isSmallScreen
                      ? Column(children: [_buildBrandingSection(context), const SizedBox(height: 48), _buildLoginCard(context)])
                      : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(flex: 5, child: _buildBrandingSection(context)),
                    const SizedBox(width: 48),
                    Expanded(flex: 7, child: _buildLoginCard(context)),
                  ]),
                ),
              ),
            ),
          ),
          // Loading Overlay
          if (_isLoading)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // 🔹 UI Helper: Branding Section (Logic Pop preserved)
  Widget _buildBrandingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.medical_services, color: Color(0xFF00629B), size: 48),
          const SizedBox(width: 12),
          Text('CliniX AI', style: TextStyle(fontFamily: 'Manrope', fontSize: 28, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.primary)),
        ]),
        const SizedBox(height: 48),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), color: Colors.black87),
        RichText(
          text: TextSpan(
            style: TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, height: 1.1),
            children: [
              const TextSpan(text: 'Precision '),
              TextSpan(text: 'Intelligence', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontStyle: FontStyle.italic)),
              const TextSpan(text: ' for Modern Practice.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Access your clinical workspace. Secure, AI-augmented healthcare management.', style: TextStyle(fontSize: 18, height: 1.5)),
      ],
    );
  }

  // 🔹 UI Helper: Login Card (Logic connected to _handleLogin)
  Widget _buildLoginCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Doctor Portal', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Please enter your medical credentials to continue.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),

              // 🔹 Email Input (Mapped to auth.py)
              _buildInputField(
                context,
                label: 'Professional Email',
                hint: 'doctor@hospital.com',
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 24),

              _buildPasswordField(context),
              const SizedBox(height: 32),

              // 🔹 Trigger Backend Auth
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF004976), Color(0xFF00629B)]),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text('Sign In to Practice', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PractitionerRegistrationPage())),
                  child: const Text('New to the network? Create Practitioner Account', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Helper Widgets (Same UI)
  Widget _buildInputField(BuildContext context, {required String label, required String hint, required IconData icon, required TextEditingController controller}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon), filled: true, fillColor: const Color(0xFFF2F3F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),
    ]);
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Secure Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          hintText: '••••••••',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
          filled: true, fillColor: const Color(0xFFF2F3F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    ]);
  }
}

// 🔹 GridPainter stays same...
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.03)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (double i = 0; i < size.width; i += 40) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += 40) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}