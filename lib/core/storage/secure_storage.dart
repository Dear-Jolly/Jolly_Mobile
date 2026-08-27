import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entity/auth_session.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _termsAgreedKey = 'terms_agreed';
  static const _nicknameRegisteredKey = 'nickname_registered';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveAuthSession(AuthSession session) async {
    await saveAccessToken(session.accessToken);
    await saveRefreshToken(session.refreshToken);
    if (session.userId != null) {
      await _storage.write(key: _userIdKey, value: session.userId.toString());
    }
    await saveTermsAgreed(session.termsAgreed);
    await saveNicknameRegistered(session.nicknameRegistered);
  }

  Future<void> saveTermsAgreed(bool agreed) =>
      _storage.write(key: _termsAgreedKey, value: agreed.toString());

  Future<bool> getTermsAgreed() async =>
      (await _storage.read(key: _termsAgreedKey)) == 'true';

  Future<void> saveNicknameRegistered(bool registered) =>
      _storage.write(key: _nicknameRegisteredKey, value: registered.toString());

  Future<bool> getNicknameRegistered() async =>
      (await _storage.read(key: _nicknameRegisteredKey)) == 'true';

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _termsAgreedKey);
    await _storage.delete(key: _nicknameRegisteredKey);
  }
}
