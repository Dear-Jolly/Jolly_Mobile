import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<Result<void>> execute() {
    return _repository.logout();
  }
}
