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

    dio.interceptors.add(_RequestMetadataInterceptor());

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

class _RequestMetadataInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = _requestIdFromHeaders(response.headers);
    if (requestId != null) {
      response.extra['requestId'] = requestId;
      if (kDebugMode) {
        debugPrint(
          '[API] ${response.statusCode} '
          '${response.requestOptions.method} '
          '${response.requestOptions.path} requestId=$requestId',
        );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final requestId = _requestIdFromHeaders(response?.headers);
    if (requestId != null) {
      response?.extra['requestId'] = requestId;
      if (kDebugMode) {
        debugPrint(
          '[API] ${response?.statusCode} '
          '${err.requestOptions.method} '
          '${err.requestOptions.path} requestId=$requestId '
          'code=${_codeFromResponse(response?.data) ?? '-'}',
        );
      }
    }
    handler.next(err);
  }

  String? _requestIdFromHeaders(Headers? headers) {
    return headers?.value('X-Request-Id') ?? headers?.value('x-request-id');
  }

  String? _codeFromResponse(Object? data) {
    if (data is Map && data['code'] is String) {
      return data['code'] as String;
    }
    return null;
  }
}
