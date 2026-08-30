import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/platform/app_info.dart';
import '../../../domain/entity/version_status.dart';
import '../../../domain/model/result.dart';
import '../../../domain/repository/version_repository.dart';
import '../data_source/version_remote_data_source.dart';

class VersionRepositoryImpl implements VersionRepository {
  final VersionRemoteDataSource _dataSource;
  final AppInfo _appInfo;

  const VersionRepositoryImpl(this._dataSource, this._appInfo);

  @override
  Future<Result<VersionStatus>> checkVersion() async {
    try {
      final dto = await _dataSource.checkVersion(
        platform: _appInfo.apiPlatform,
        appVersion: await _appInfo.appVersion,
      );
      return Success(dto.toEntity());
    } on DioException catch (e) {
      return Failure(ApiException.fromDioException(e).message);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
