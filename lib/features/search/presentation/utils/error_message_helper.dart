import 'package:skipthebrowse/features/search/domain/exceptions/search_exceptions.dart';

/// Helper class to extract user-friendly error messages
class ErrorMessageHelper {
  /// Get user-friendly error message from exception
  static String getMessage(Object error) {
    if (error is SearchException) {
      return error.userMessage ?? error.message;
    }

    // Fallback for unexpected errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Check if error is retryable (user should try again)
  static bool isRetryable(Object error) {
    if (error is SearchNetworkException) return true;
    if (error is SearchTimeoutException) return true;
    if (error is SearchServerException) return true;

    return false;
  }

  /// Check if error requires user action (not just retry)
  static bool requiresUserAction(Object error) {
    if (error is SearchUnauthorizedException) return true;
    if (error is SearchValidationException) return true;

    return false;
  }

  /// Get action label for error (e.g., "Retry", "Login", "Go Back")
  static String getActionLabel(Object error) {
    if (error is SearchUnauthorizedException) {
      return 'Log In';
    }

    if (error is SearchNotFoundException) {
      return 'Go Back';
    }

    if (isRetryable(error)) {
      return 'Retry';
    }

    return 'OK';
  }

  /// Get icon for error type
  static String getErrorIcon(Object error) {
    if (error is SearchNetworkException) {
      return '📡'; // No connection
    }

    if (error is SearchTimeoutException) {
      return '⏱️'; // Timeout
    }

    if (error is SearchServerException) {
      return '🔧'; // Server issue
    }

    if (error is SearchUnauthorizedException) {
      return '🔐'; // Auth required
    }

    if (error is SearchValidationException) {
      return '⚠️'; // Validation error
    }

    if (error is SearchNotFoundException) {
      return '🔍'; // Not found
    }

    return '❌'; // Generic error
  }
}
