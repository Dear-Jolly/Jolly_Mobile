import '../entity/user.dart';
import '../model/result.dart';

abstract class AuthRepository {
  Future<Result<User>> loginWithKakao();
  Future<Result<User>> loginWithApple();
  Future<Result<void>> logout();
  Future<Result<void>> deleteAccount();
  Future<Result<User>> registerNickname(String nickname);
  Future<Result<User>> updateNickname(String nickname);
  Future<Result<User>> getUser();
}
