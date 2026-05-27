import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('연결 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = switch (statusCode) {
          400 => '잘못된 요청입니다.',
          401 => '인증이 필요합니다.',
          403 => '접근이 거부되었습니다.',
          404 => '요청한 리소스를 찾을 수 없습니다.',
          500 => '서버 오류가 발생했습니다.',
          _ => '오류가 발생했습니다. ($statusCode)',
        };
        return ApiException(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiException('요청이 취소되었습니다.');
      case DioExceptionType.connectionError:
        return ApiException('네트워크 연결을 확인해주세요.');
      default:
        return ApiException('알 수 없는 오류가 발생했습니다.');
    }
  }

  @override
  String toString() => message;
}
