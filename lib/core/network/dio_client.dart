import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio create({SecureStorage? secureStorage}) {
    final dio = Dio(
      BaseOptions(
        // TODO: 실제 API base URL로 변경
        baseUrl: 'https://api.example.com/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (secureStorage != null) {
      dio.interceptors.add(AuthInterceptor(secureStorage));
    }

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );

    return dio;
  }
}