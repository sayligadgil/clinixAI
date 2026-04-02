import 'dart:ui';
import 'package:flutter/material.dart';

class PractitionerRegistrationPage extends StatefulWidget {
  const PractitionerRegistrationPage({Key? key}) : super(key: key);

  @override
  State<PractitionerRegistrationPage> createState() =>
      _PractitionerRegistrationPageState();
}

class _PractitionerRegistrationPageState
    extends State<PractitionerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedSpecialization = 'General Practice';

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _hospitalController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Colors.white.withOpacity(0.8),
                surfaceTintColor: Colors.transparent,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Image.asset(
                      'assets/finallogo.png', // 👈 your logo path
                      height: 28,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.medical_services,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'CliniX AI',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (MediaQuery.of(context).size.width >= 768) ...[
                    TextButton(
                      onPressed: () {},
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Support'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('About'),
                    ),
                    const SizedBox(width: 16),
                  ],
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 120,
                    left: 16,
                    right: 16,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLargeScreen = constraints.maxWidth >= 1024;

                      if (isLargeScreen) {
                        return _buildTwoColumnLayout(context);
                      } else {
                        return _buildSingleColumnLayout(context);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation (Mobile)
          if (MediaQuery.of(context).size.width < 768)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigation(context),
            ),
        ],
      ),
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1280),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero/Branding Column
          Expanded(
            flex: 5,
            child: _buildHeroSection(context),
          ),
          const SizedBox(width: 48),
          // Form Column
          Expanded(
            flex: 7,
            child: _buildRegistrationForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeroSection(context),
        const SizedBox(height: 48),
        _buildRegistrationForm(context),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFC2E8FF),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            'PRACTITIONER PORTAL',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Headline
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              fontSize: 40,
              color: Theme.of(context).colorScheme.primary,
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Empowering Healthcare with '),
              TextSpan(
                text: 'AI Precision',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Description
        Text(
          'Join an elite network of medical professionals leveraging advanced diagnostics and collaborative intelligence to improve patient outcomes globally.',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        // Image with overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuABhDXgL6k9NB5g3rFKIbdnYekB0aak3Q0Nf5sYvC4Vg2JFpXRILihT61EiJ_GXar-8jNmFcZECaTpnXl-b0356D6iSOFdVza4cXoDK-mx4my6_B-5opcdkiap3zKSwouzTif0JAugHz1q9HCCTDaGNiMWRW_HzmYpo3t8vg_IzDwKNwA0Vb978t42Bxb-5-YlL1xk3nITFC2WdL2Szu-DvoMDeVBiAjg-36E6HAPWljps9xa122IKpzOTnzOwda6e2ndFDJZUG4nQ',
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              // Badge at bottom
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HIPAA Compliant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Industry-standard encryption & privacy',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.1),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Personal Details
            _buildSectionHeader(context, '01', 'Personal Details'),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    context,
                    label: 'Full Name',
                    placeholder: 'Dr. Julian Sterling',
                    controller: _fullNameController,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    context,
                    label: 'Age',
                    placeholder: '38',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Section 2: Professional Credentials
            _buildSectionHeader(context, '02', 'Professional Credentials'),
            const SizedBox(height: 24),
            _buildTextField(
              context,
              label: 'Hospital/Facility Affiliation',
              placeholder: 'St. Lukes International Medical Center',
              controller: _hospitalController,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDropdownField(
                    context,
                    label: 'Specialization',
                    value: _selectedSpecialization,
                    items: [
                      'General Practice',
                      'Cardiology',
                      'Neurology',
                      'Oncology',
                      'Pediatrics',
                      'Radiology',
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecialization = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Medical License Number',
                    placeholder: 'LIC-99827-BC',
                    controller: _licenseController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Section 3: Account Security
            _buildSectionHeader(context, '03', 'Account Security'),
            const SizedBox(height: 24),
            _buildTextField(
              context,
              label: 'Email Address',
              placeholder: 'j.sterling@hospital.org',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Create Password',
                    placeholder: '••••••••',
                    controller: _passwordController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildTextField(
                    context,
                    label: 'Confirm Password',
                    placeholder: '••••••••',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Submit Button
            Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(9999),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle registration
                    }
                  },
                  borderRadius: BorderRadius.circular(9999),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Practitioner Account',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sign in link
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Text('Already have an account? Sign In'),
                label: const Icon(Icons.login, size: 18),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String number, String title) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
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
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.how_to_reg,
                label: 'REGISTER',
                isActive: true,
              ),
              _buildNavItem(
                context,
                icon: Icons.contact_support,
                label: 'SUPPORT',
                isActive: false,
              ),
              _buildNavItem(
                context,
                icon: Icons.info,
                label: 'ABOUT',
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDEEBF7) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
