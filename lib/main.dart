import 'package:flutter/material.dart';
import 'frontend/Patient_Interface/clinix_splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ← changed from CliniXSplashScreen
    );
  }
}