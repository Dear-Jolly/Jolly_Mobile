enum LoginProvider { kakao, apple }

class User {
  final int? id;
  final String? nickname;
  final LoginProvider loginProvider;
  final String? email;
  final bool marketingAgreed;

  const User({
    this.id,
    this.nickname,
    required this.loginProvider,
    this.email,
    this.marketingAgreed = false,
  });

  User copyWith({
    int? id,
    String? nickname,
    LoginProvider? loginProvider,
    String? email,
    bool? marketingAgreed,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      loginProvider: loginProvider ?? this.loginProvider,
      email: email ?? this.email,
      marketingAgreed: marketingAgreed ?? this.marketingAgreed,
    );
  }
}
