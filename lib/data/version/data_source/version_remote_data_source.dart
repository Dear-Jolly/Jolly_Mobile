import 'package:dio/dio.dart';

import '../dto/version_dto.dart';

class VersionRemoteDataSource {
  final Dio _dio;

  const VersionRemoteDataSource(this._dio);

  Future<VersionDto> checkVersion({
    required String platform,
    required String appVersion,
  }) async {
    final response = await _dio.get(
      '/version',
      queryParameters: {'platform': platform, 'appVersion': appVersion},
    );
    return VersionDto.fromJson(response.data as Map<String, dynamic>);
  }
}
