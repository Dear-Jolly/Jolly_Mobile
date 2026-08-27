import 'package:flutter/foundation.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../domain/model/result.dart';
import '../../../domain/usecase/auth/get_user_usecase.dart';

class SplashViewModel extends ChangeNotifier {
  final SecureStorage _secureStorage;
  final GetUserUseCase _getUserUseCase;

  SplashViewModel(this._secureStorage, this._getUserUseCase);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<String> initialize() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return _finish('/login');
    }

    final termsAgreed = await _secureStorage.getTermsAgreed();
    if (!termsAgreed) {
      return _finish('/onboarding/terms');
    }

    final nicknameRegistered = await _secureStorage.getNicknameRegistered();
    if (!nicknameRegistered) {
      return _finish('/onboarding/nickname');
    }

    final result = await _getUserUseCase.execute();
    switch (result) {
      case Success(data: final user):
        return _finish(
          user.nickname == null ? '/onboarding/nickname' : '/home',
        );
      case Failure():
        await _secureStorage.clearTokens();
        return _finish('/login');
    }
  }

  String _finish(String route) {
    _isLoading = false;
    notifyListeners();
    return route;
  }
}
