class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'local',
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  static bool get isDevelopment => environment == 'dev';
  static bool get isProduction => environment == 'prod';
  static bool get isLocal => environment == 'local';

  static bool get isSentryEnabled => sentryDsn.isNotEmpty && !isLocal;
}
