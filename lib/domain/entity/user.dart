enum LoginProvider { kakao, apple }

class User {
  final int id;
  final String nickname;
  final LoginProvider loginProvider;
  final int stampCount;

  const User({
    required this.id,
    required this.nickname,
    required this.loginProvider,
    this.stampCount = 0,
  });

  User copyWith({
    int? id,
    String? nickname,
    LoginProvider? loginProvider,
    int? stampCount,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      loginProvider: loginProvider ?? this.loginProvider,
      stampCount: stampCount ?? this.stampCount,
    );
  }
}
