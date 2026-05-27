class TokenDto {
  final String accessToken;
  final String refreshToken;

  const TokenDto({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
