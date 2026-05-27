import 'package:flutter/foundation.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    // TODO: 초기화 로직 (토큰 확인, 설정 로드 등)
    await Future.delayed(const Duration(seconds: 2));

    _isLoading = false;
    notifyListeners();
  }
}
