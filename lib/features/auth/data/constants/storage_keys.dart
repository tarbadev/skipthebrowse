/// Storage keys for authentication data in FlutterSecureStorage
class AuthStorageKeys {
  /// Key for storing the access token
  static const String token = 'auth_token';

  /// Key for storing the token type (e.g., 'bearer')
  static const String tokenType = 'token_type';

  /// Key for storing user data as JSON
  static const String user = 'user';

  const AuthStorageKeys._();
}
