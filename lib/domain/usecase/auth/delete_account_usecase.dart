import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  const DeleteAccountUseCase(this._repository);

  Future<Result<void>> execute() {
    return _repository.deleteAccount();
  }
}
