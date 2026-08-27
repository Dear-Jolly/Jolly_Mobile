import '../../../domain/entity/auth_session.dart';

class TokenDto {
  final String accessToken;
  final String refreshToken;

  const TokenDto({required this.accessToken, required this.refreshToken});

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

class AuthSessionDto {
  final String accessToken;
  final String refreshToken;
  final int? userId;
  final bool isNewUser;
  final bool termsAgreed;
  final bool nicknameRegistered;

  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    required this.isNewUser,
    required this.termsAgreed,
    required this.nicknameRegistered,
  });

  factory AuthSessionDto.fromUri(Uri uri) {
    final params = uri.queryParameters;
    final accessToken = params['accessToken'];
    final refreshToken = params['refreshToken'];

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const FormatException('로그인 토큰을 찾을 수 없습니다.');
    }

    return AuthSessionDto(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: int.tryParse(params['userId'] ?? ''),
      isNewUser: _parseBool(params['isNewUser']),
      termsAgreed: _parseBool(params['termsAgreed']),
      nicknameRegistered: _parseBool(params['nicknameRegistered']),
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      isNewUser: isNewUser,
      termsAgreed: termsAgreed,
      nicknameRegistered: nicknameRegistered,
    );
  }

  static bool _parseBool(String? value) => value?.toLowerCase() == 'true';
}
