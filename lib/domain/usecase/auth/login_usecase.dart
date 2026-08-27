import '../../entity/auth_session.dart';
import '../../entity/user.dart';
import '../../model/result.dart';
import '../../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Uri authorizationUri(LoginProvider provider) {
    return _repository.getAuthorizationUri(provider);
  }

  Future<Result<AuthSession>> completeWithCallback(Uri callbackUri) {
    return _repository.completeSocialLogin(callbackUri);
  }
}
