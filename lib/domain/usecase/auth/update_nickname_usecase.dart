import '../../entity/user.dart';
import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class UpdateNicknameUseCase {
  final AuthRepository _repository;

  const UpdateNicknameUseCase(this._repository);

  Future<Result<User>> execute(String nickname) {
    return _repository.updateNickname(nickname);
  }
}
