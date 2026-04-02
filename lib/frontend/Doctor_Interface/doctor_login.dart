import 'package:flutter/material.dart';
import 'doctor_registration_page.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _doctorIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 1024;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          // Decorative gradient blobs
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.1,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC2E8FF).withOpacity(0.3),
                    const Color(0xFFC2E8FF).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.1,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE0E0FF).withOpacity(0.2),
                    const Color(0xFFE0E0FF).withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          // Grid background
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 24 : 48,
                  vertical: 48,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isSmallScreen
                      ? Column(
                          children: [
                            _buildBrandingSection(context),
                            const SizedBox(height: 48),
                            _buildLoginCard(context),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildBrandingSection(context),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              flex: 7,
                              child: _buildLoginCard(context),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Row(
          children: [
            Image.asset(
              'assets/finallogo.png',
              height: 48,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_services, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'CliniX AI',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        // Main headline
        IconButton(
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black87, // match your theme
          tooltip: 'Back',
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.1,
              letterSpacing: -1,
            ),
            children: [
              const TextSpan(text: 'Precision '),
              TextSpan(
                text: 'Intelligence',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const TextSpan(text: ' for Modern Practice.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Access your clinical workspace. Secure, AI-augmented healthcare management designed for the discerning practitioner.',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        // Feature badges
        _buildFeatureBadge(
          context,
          icon: Icons.verified_user,
          title: 'HIPAA Compliant',
          subtitle: 'Enterprise-grade encryption and security protocols.',
          backgroundColor: const Color(0xFFC2E8FF),
          iconColor: const Color(0xFF005370),
        ),
        const SizedBox(height: 24),
        _buildFeatureBadge(
          context,
          icon: Icons.psychology,
          title: 'AI Diagnostics',
          subtitle: 'Seamlessly integrated clinical decision support.',
          backgroundColor: const Color(0xFFCEE5FF),
          iconColor: const Color(0xFF004A77),
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative gradient
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFC2E8FF).withOpacity(0.1),
                        const Color(0xFFC2E8FF).withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(48),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Doctor Portal',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your medical credentials to continue.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Doctor ID Input
                      _buildInputField(
                        context,
                        label: 'Provider Identification ID',
                        hint: 'NPI or Facility ID',
                        icon: Icons.badge_outlined,
                        controller: _doctorIdController,
                      ),
                      const SizedBox(height: 24),
                      // Password Input
                      _buildPasswordField(context),
                      const SizedBox(height: 32),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Handle login
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            elevation: 0,
                            shadowColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ).copyWith(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) {
                                return Theme.of(context).colorScheme.primary;
                              },
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF004976), Color(0xFF00629B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Sign In to Practice',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Divider
                      Divider(
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withOpacity(0.2),
                      ),
                      const SizedBox(height: 32),
                      // Sign up section
                      Column(
                        children: [
                          Text(
                            'New to the CliniAI network?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const PractitionerRegistrationPage(),
                                  ),
                                );
                                // Handle sign up
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFE6E8ED),
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: const Text(
                                'Create Practitioner Account',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Security badges
        Opacity(
          opacity: 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSecurityBadge(context, Icons.lock, '256-BIT SSL'),
              _buildSecurityBadge(context, Icons.shield, 'ENCRYPTED DATA'),
              _buildSecurityBadge(
                  context, Icons.fingerprint, 'BIOMETRIC READY'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Secure Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Forgot?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: const Color(0xFFF2F3F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityBadge(
      BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// Custom painter for grid background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
