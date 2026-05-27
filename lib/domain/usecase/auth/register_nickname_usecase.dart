import '../../entity/user.dart';
import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class RegisterNicknameUseCase {
  final AuthRepository _repository;

  const RegisterNicknameUseCase(this._repository);

  Future<Result<User>> execute(String nickname) {
    return _repository.registerNickname(nickname);
  }
}
