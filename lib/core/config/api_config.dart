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

  static const defaultTimeZone = String.fromEnvironment(
    'JOLLY_TIME_ZONE',
    defaultValue: 'Asia/Seoul',
  );
}
