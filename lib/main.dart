import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This file is created by running 'flutterfire configure'
import 'frontend/Patient_Interface/clinix_splash_screen.dart';
import 'frontend/Patient_Interface/user_selection_screen.dart';
import 'frontend/Patient_Interface/patient_intake_screen.dart';
import 'frontend/Doctor_Interface/doctor_dashboard.dart';

import 'package:flutter/foundation.dart'; // Required for kDebugMode
import 'package:cloud_firestore/cloud_firestore.dart';
// Ensure this path matches your structure

void main() async {
  // 1. Ensure Flutter bindings are initialized for Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase before the app starts
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Only connect to the Firestore emulator when explicitly requested.
  // Set USE_EMULATOR=true in your launch config / run args to enable.
  const bool useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  if (useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(kIsWeb ? 'localhost' : '10.0.2.2', 8080);
    debugPrint("🔌 Connected to Firestore Emulator");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CliniX AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 3. Set the initial route to your Splash Screen
      initialRoute: '/',
      routes: {
        '/': (context) => const CliniXSplashScreen(),
        '/user_selection': (context) => const UserSelectionScreen(),
        '/patient_home': (context) => const PatientIntakeScreen(),
        // Define additional routes for doctor and patient logic here
        '/doctor_dashboard': (context) => const DoctorDashboard(),
      },
    );
  }
}

