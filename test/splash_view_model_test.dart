import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jolly_mobile/core/storage/secure_storage.dart';
import 'package:jolly_mobile/domain/entity/auth_session.dart';
import 'package:jolly_mobile/domain/entity/user.dart';
import 'package:jolly_mobile/domain/entity/version_status.dart';
import 'package:jolly_mobile/domain/model/result.dart';
import 'package:jolly_mobile/domain/repository/auth_repository.dart';
import 'package:jolly_mobile/domain/repository/version_repository.dart';
import 'package:jolly_mobile/domain/usecase/auth/get_user_usecase.dart';
import 'package:jolly_mobile/domain/usecase/version/check_version_usecase.dart';
import 'package:jolly_mobile/features/splash/view_model/splash_view_model.dart';

void main() {
  test(
    'deleted account local session is cleared before onboarding routing',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'access_token': 'access-token',
        'refresh_token': 'refresh-token',
        'terms_agreed': 'false',
        'nickname_registered': 'false',
      });
      final storage = SecureStorage();
      final viewModel = SplashViewModel(
        storage,
        GetUserUseCase(_FakeAuthRepository(const Failure('이미 탈퇴한 회원입니다.'))),
        CheckVersionUseCase(_FakeVersionRepository()),
      );

      final route = await viewModel.initialize();

      expect(route, '/login');
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
      expect(await storage.getTermsAgreed(), isFalse);
      expect(await storage.getNicknameRegistered(), isFalse);
    },
  );
}

class _FakeVersionRepository implements VersionRepository {
  @override
  Future<Result<VersionStatus>> checkVersion() async {
    return const Success(
      VersionStatus(minSupportedVersion: '1.0.0', forceUpdate: false),
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  final Result<User> _userResult;

  const _FakeAuthRepository(this._userResult);

  @override
  Future<Result<User>> getUser() async => _userResult;

  @override
  Future<Result<void>> agreeTerms({
    required bool serviceAgreed,
    required bool privacyAgreed,
    required bool marketingAgreed,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession>> completeSocialLogin(Uri callbackUri) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteAccount() {
    throw UnimplementedError();
  }

  @override
  Uri getAuthorizationUri(LoginProvider provider) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<Result<User>> registerNickname(String nickname) {
    throw UnimplementedError();
  }

  @override
  Future<Result<User>> updateNickname(String nickname) {
    throw UnimplementedError();
  }
}
