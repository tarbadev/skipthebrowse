/// Base exception for all search-related errors
abstract class SearchException implements Exception {
  final String message;
  final String? userMessage;
  final Object? originalError;

  const SearchException(this.message, {this.userMessage, this.originalError});

  @override
  String toString() => 'SearchException: $message';
}

/// Thrown when there's no network connectivity
class SearchNetworkException extends SearchException {
  const SearchNetworkException({
    super.userMessage =
        'No internet connection. Please check your network and try again.',
    super.originalError,
  }) : super('Network error occurred');
}

/// Thrown when the request times out
class SearchTimeoutException extends SearchException {
  const SearchTimeoutException({
    super.userMessage =
        'Request timed out. Please check your connection and try again.',
    super.originalError,
  }) : super('Request timeout');
}

/// Thrown when server returns 5xx errors
class SearchServerException extends SearchException {
  final int? statusCode;

  const SearchServerException({
    this.statusCode,
    super.userMessage =
        'Server error occurred. Please try again in a few moments.',
    super.originalError,
  }) : super('Server error (${statusCode ?? "unknown"})');
}

/// Thrown when client request is invalid (4xx errors except 401/404)
class SearchValidationException extends SearchException {
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;

  const SearchValidationException({
    required String message,
    this.statusCode,
    this.validationErrors,
    super.userMessage,
    super.originalError,
  }) : super(message);
}

/// Thrown when user is not authenticated (401)
class SearchUnauthorizedException extends SearchException {
  const SearchUnauthorizedException({
    super.userMessage = 'Your session has expired. Please log in again.',
    super.originalError,
  }) : super('Unauthorized (401)');
}

/// Thrown when resource is not found (404)
class SearchNotFoundException extends SearchException {
  final String? resourceType;
  final String? resourceId;

  const SearchNotFoundException({
    this.resourceType,
    this.resourceId,
    super.userMessage = 'The requested item could not be found.',
    super.originalError,
  }) : super(
         'Resource not found: ${resourceType ?? "unknown"} ${resourceId ?? ""}',
       );
}

/// Thrown when response parsing fails
class SearchParseException extends SearchException {
  const SearchParseException({
    super.userMessage = 'Unable to process server response. Please try again.',
    super.originalError,
  }) : super('Failed to parse response');
}

/// Thrown for unknown/unhandled errors
class SearchUnknownException extends SearchException {
  const SearchUnknownException({
    required String message,
    super.userMessage = 'An unexpected error occurred. Please try again.',
    super.originalError,
  }) : super(message);
}
