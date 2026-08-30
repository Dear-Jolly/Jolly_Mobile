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

  static const iosStoreUrl = String.fromEnvironment('JOLLY_IOS_STORE_URL');

  static const androidStoreUrl = String.fromEnvironment('JOLLY_AOS_STORE_URL');

  static const defaultTimeZone = String.fromEnvironment(
    'JOLLY_TIME_ZONE',
    defaultValue: 'Asia/Seoul',
  );
}
