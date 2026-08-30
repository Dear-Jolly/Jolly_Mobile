import '../../entity/version_status.dart';
import '../../model/result.dart';
import '../../repository/version_repository.dart';

class CheckVersionUseCase {
  final VersionRepository _repository;

  const CheckVersionUseCase(this._repository);

  Future<Result<VersionStatus>> execute() {
    return _repository.checkVersion();
  }
}
