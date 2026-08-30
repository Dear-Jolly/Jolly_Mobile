import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final Dio _refreshDio;
  final SecureStorage _secureStorage;
  Future<String?>? _refreshingToken;

  AuthInterceptor({
    required Dio dio,
    required SecureStorage secureStorage,
    required Dio refreshDio,
  }) : _dio = dio,
       _secureStorage = secureStorage,
       _refreshDio = refreshDio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && !_isPublicRequest(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra['authRetried'] == true;
    final canRefresh =
        err.response?.statusCode == 401 &&
        !alreadyRetried &&
        !requestOptions.path.contains('/auth/reissue');

    if (!canRefresh) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null) {
      await _secureStorage.clearAuthState();
      handler.next(err);
      return;
    }

    requestOptions.extra['authRetried'] = true;
    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    try {
      final response = await _dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<String?> _refreshAccessToken() {
    _refreshingToken ??= _doRefreshAccessToken().whenComplete(() {
      _refreshingToken = null;
    });
    return _refreshingToken!;
  }

  Future<String?> _doRefreshAccessToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/reissue',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data;
      final accessToken = data?['accessToken'] as String?;
      final nextRefreshToken = data?['refreshToken'] as String?;
      if (accessToken == null || nextRefreshToken == null) {
        return null;
      }
      await _secureStorage.saveAccessToken(accessToken);
      await _secureStorage.saveRefreshToken(nextRefreshToken);
      return accessToken;
    } on DioException {
      return null;
    }
  }

  bool _isPublicRequest(String path) {
    return path == '/version';
  }
}
