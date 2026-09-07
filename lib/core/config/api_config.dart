class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'JOLLY_API_BASE_URL',
    defaultValue: 'https://43-201-80-36.sslip.io/api/v1',
  );

  static const authCallbackScheme = String.fromEnvironment(
    'JOLLY_AUTH_SCHEME',
    defaultValue: 'dearjolly',
  );

  static const appVersion = String.fromEnvironment(
    'JOLLY_APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// App Store 앱 ID 6808617546 (com.dearjolly.app).
  static const iosStoreUrl = String.fromEnvironment(
    'JOLLY_IOS_STORE_URL',
    defaultValue: 'https://apps.apple.com/app/id6808617546',
  );

  static const androidStoreUrl = String.fromEnvironment('JOLLY_AOS_STORE_URL');

  static const defaultTimeZone = String.fromEnvironment(
    'JOLLY_TIME_ZONE',
    defaultValue: 'Asia/Seoul',
  );

  /// 서비스 이용약관 원문. App Store 심사 시 앱 안에서 열람 가능해야 한다.
  static const termsOfServiceUrl = String.fromEnvironment(
    'JOLLY_TERMS_URL',
    defaultValue: 'https://yeonjeen-0821.notion.site/service-agree',
  );

  /// 개인정보 처리방침 원문. App Store 심사 시 앱 안에서 열람 가능해야 한다.
  static const privacyPolicyUrl = String.fromEnvironment(
    'JOLLY_PRIVACY_URL',
    defaultValue: 'https://yeonjeen-0821.notion.site/privacy',
  );

  /// 마케팅 정보 수신 동의 안내.
  static const marketingConsentUrl = String.fromEnvironment(
    'JOLLY_MARKETING_URL',
    defaultValue: 'https://yeonjeen-0821.notion.site/marketing',
  );

  /// 공지사항 페이지. 비어 있으면 설정 화면에서 메뉴 자체를 숨긴다.
  static const noticeUrl = String.fromEnvironment('JOLLY_NOTICE_URL');

  static Uri? _uriOrNull(String value) {
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    return uri;
  }

  static Uri? get termsOfServiceUri => _uriOrNull(termsOfServiceUrl);

  static Uri? get privacyPolicyUri => _uriOrNull(privacyPolicyUrl);

  static Uri? get marketingConsentUri => _uriOrNull(marketingConsentUrl);

  static Uri? get noticeUri => _uriOrNull(noticeUrl);
}
