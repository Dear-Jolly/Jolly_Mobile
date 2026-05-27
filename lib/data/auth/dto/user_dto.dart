import '../../../domain/entity/user.dart';

class UserDto {
  final int id;
  final String nickname;
  final String loginProvider;
  final int stampCount;

  const UserDto({
    required this.id,
    required this.nickname,
    required this.loginProvider,
    this.stampCount = 0,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      nickname: json['nickname'] as String,
      loginProvider: json['loginProvider'] as String,
      stampCount: json['stampCount'] as int? ?? 0,
    );
  }

  User toEntity() {
    return User(
      id: id,
      nickname: nickname,
      loginProvider: switch (loginProvider) {
        'APPLE' => LoginProvider.apple,
        _ => LoginProvider.kakao,
      },
      stampCount: stampCount,
    );
  }
}
