import '../../../domain/entity/user.dart';

class UserDto {
  final int? id;
  final String? nickname;
  final String provider;
  final String? email;
  final bool marketingAgreed;

  const UserDto({
    this.id,
    this.nickname,
    required this.provider,
    this.email,
    required this.marketingAgreed,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int?,
      nickname: json['nickname'] as String?,
      provider:
          (json['provider'] ?? json['loginProvider'] ?? 'KAKAO') as String,
      email: json['email'] as String?,
      marketingAgreed: json['marketingAgreed'] as bool? ?? false,
    );
  }

  User toEntity() {
    return User(
      id: id,
      nickname: nickname,
      loginProvider: switch (provider) {
        'APPLE' => LoginProvider.apple,
        _ => LoginProvider.kakao,
      },
      email: email,
      marketingAgreed: marketingAgreed,
    );
  }
}

class NicknameUpdateDto {
  final String nickname;

  const NicknameUpdateDto({required this.nickname});

  factory NicknameUpdateDto.fromJson(Map<String, dynamic> json) {
    return NicknameUpdateDto(nickname: json['nickname'] as String);
  }
}

class TermsAgreeDto {
  final bool termsAgreed;

  const TermsAgreeDto({required this.termsAgreed});

  factory TermsAgreeDto.fromJson(Map<String, dynamic> json) {
    return TermsAgreeDto(termsAgreed: json['termsAgreed'] as bool? ?? false);
  }
}
