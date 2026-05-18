import 'package:dio/dio.dart';
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
