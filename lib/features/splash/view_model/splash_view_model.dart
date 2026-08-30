import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../domain/entity/version_status.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/auth/get_user_usecase.dart';
import '../../../domain/usecase/version/check_version_usecase.dart';

class SplashViewModel extends ChangeNotifier {
  final SecureStorage _secureStorage;
  final GetUserUseCase _getUserUseCase;
  final CheckVersionUseCase _checkVersionUseCase;

  SplashViewModel(
    this._secureStorage,
    this._getUserUseCase,
    this._checkVersionUseCase,
  );

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<String> initialize() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final versionResult = await _checkVersionUseCase.execute();
    if (versionResult case Success<VersionStatus>(
      data: final version,
    ) when version.forceUpdate) {
      return _finish('/force-update');
    }

    final accessToken = await _secureStorage.getAccessToken();
    final refreshToken = await _secureStorage.getRefreshToken();
    final hasValidLocalTokens =
        accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;

    if (!hasValidLocalTokens) {
      await _secureStorage.clearAuthState();
      return _finish('/login');
    }

    final result = await _getUserUseCase.execute();
    switch (result) {
      case Failure():
        await _secureStorage.clearAuthState();
        return _finish('/login');
      case Success(data: final user):
        await _secureStorage.saveNicknameRegistered(user.nickname != null);
    }

    final termsAgreed = await _secureStorage.getTermsAgreed();
    if (!termsAgreed) {
      return _finish('/onboarding/terms');
    }

    final nicknameRegistered = await _secureStorage.getNicknameRegistered();
    if (!nicknameRegistered) {
      return _finish('/onboarding/nickname');
    }

    return _finish('/home');
  }

  String _finish(String route) {
    _isLoading = false;
    notifyListeners();
    return route;
  }
}
