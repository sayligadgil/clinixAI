import 'package:flutter/material.dart';
import 'package:clinixai/core/api_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'frontend/Patient_Interface/clinix_splash_screen.dart';
import 'frontend/Patient_Interface/user_selection_screen.dart';
import 'frontend/Patient_Interface/patient_intake_screen.dart';
import 'frontend/Doctor_Interface/doctor_dashboard.dart';
import 'package:flutter/foundation.dart'; // Required for kDebugMode
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const bool useEmulator = bool.fromEnvironment('USE_EMULATOR', defaultValue: false);
  if (useEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator(kIsWeb ? 'localhost' : '10.0.2.2', 8080);
    debugPrint('🔌 Connected to Firestore Emulator');
  }
  initializeApiClient();
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
      initialRoute: '/',
      routes: {
        '/': (context) => const CliniXSplashScreen(),
        '/user_selection': (context) => const UserSelectionScreen(),
        '/patient_home': (context) => const PatientIntakeScreen(),
        '/doctor_dashboard': (context) => const DoctorDashboard(),
      },
    );
  }
}
