import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio create({SecureStorage? secureStorage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (secureStorage != null) {
      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          secureStorage: secureStorage,
          refreshDio: Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
        ),
      );
    }

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }

    return dio;
  }
}
