import '../entity/auth_session.dart';
import '../entity/user.dart';
import '../model/result.dart';

abstract class AuthRepository {
  Uri getAuthorizationUri(LoginProvider provider);
  Future<Result<AuthSession>> completeSocialLogin(Uri callbackUri);
  Future<Result<void>> agreeTerms({
    required bool serviceAgreed,
    required bool privacyAgreed,
    required bool marketingAgreed,
  });
  Future<Result<void>> logout();
  Future<Result<void>> deleteAccount();
  Future<Result<User>> registerNickname(String nickname);
  Future<Result<User>> updateNickname(String nickname);
  Future<Result<User>> getUser();
}
