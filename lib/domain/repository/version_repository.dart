import '../entity/version_status.dart';
import '../model/result.dart';

abstract class VersionRepository {
  Future<Result<VersionStatus>> checkVersion();
}
