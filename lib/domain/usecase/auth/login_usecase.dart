import '../../entity/user.dart';
import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<User>> executeWithKakao() {
    return _repository.loginWithKakao();
  }

  Future<Result<User>> executeWithApple() {
    return _repository.loginWithApple();
  }
}
