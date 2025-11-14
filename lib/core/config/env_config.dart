class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'local',
  );

  static bool get isDevelopment => environment == 'dev';
  static bool get isProduction => environment == 'prod';
  static bool get isLocal => environment == 'local';
}
