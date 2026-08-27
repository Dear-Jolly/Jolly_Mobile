class AuthSession {
  final String accessToken;
  final String refreshToken;
  final int? userId;
  final bool isNewUser;
  final bool termsAgreed;
  final bool nicknameRegistered;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    this.userId,
    required this.isNewUser,
    required this.termsAgreed,
    required this.nicknameRegistered,
  });

  bool get isOnboardingComplete => termsAgreed && nicknameRegistered;
}
