import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Create a globally accessible Dio instance configured with standard options.
final Dio dioClient = Dio(
  BaseOptions(
    // 10.0.2.2 is the special IP address mapped by Android Emulator to the host machine's localhost (127.0.0.1)
    baseUrl: kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ),
);

void _setupAuthInterceptor() {
  dioClient.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final idToken = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $idToken';
        }
      } catch (e) {
        // If token retrieval fails, proceed without auth header; backend will reject.
      }
      return handler.next(options);
    },
  ));
}

// Initialize interceptor
void initializeApiClient() {
  _setupAuthInterceptor();
}
