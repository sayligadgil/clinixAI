import 'dart:ui';
import 'package:flutter/material.dart';

class CliniXSplashScreen extends StatelessWidget {
  const CliniXSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Colors.white,
                  Color(0xFFF2F3F9),
                ],
              ),
            ),
          ),

          // Top Right Blur Circle
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFC2E8FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Bottom Left Blur Circle
          Positioned(
            bottom: -120,
            left: -120,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFFCEE5FF).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with Glass Effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF004976).withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Glass Container
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              "assets/finallogo.png",
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Title
                const Text(
                  "CliniX AI",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF004976),
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle with lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 1,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "CLINICAL INTELLIGENCE",
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF414750),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 30,
                      height: 1,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Progress Bar
                Container(
                  width: 180,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEEF3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF004976),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF004976).withOpacity(0.3),
                            blurRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified_user, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "SECURE CLINICAL ENVIRONMENT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: Colors.grey,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'user_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UserSelectionScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("ClinixAI Splash Screen"),
      ),
    );
  }
}