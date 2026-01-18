/// Base exception for authentication-related errors
abstract class AuthException implements Exception {
  final String message;
  final Object? originalError;

  const AuthException(this.message, {this.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when storage operations fail
class AuthStorageException extends AuthException {
  const AuthStorageException(super.message, {super.originalError});

  @override
  String toString() => 'AuthStorageException: $message';
}

/// Exception thrown when data validation fails
class AuthDataValidationException extends AuthException {
  const AuthDataValidationException(super.message, {super.originalError});

  @override
  String toString() => 'AuthDataValidationException: $message';
}
