import '../../entity/user.dart';
import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class GetUserUseCase {
  final AuthRepository _repository;

  const GetUserUseCase(this._repository);

  Future<Result<User>> execute() {
    return _repository.getUser();
  }
}
