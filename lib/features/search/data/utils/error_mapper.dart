import 'dart:io';
import 'package:dio/dio.dart';
import 'package:skipthebrowse/features/search/domain/exceptions/search_exceptions.dart';

/// Maps Dio errors to domain-specific search exceptions
class SearchErrorMapper {
  /// Convert DioException to SearchException
  static SearchException mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return SearchTimeoutException(originalError: error);

      case DioExceptionType.badResponse:
        return _mapHttpError(error);

      case DioExceptionType.cancel:
        return const SearchUnknownException(
          message: 'Request was cancelled',
          userMessage: 'Request was cancelled. Please try again.',
        );

      case DioExceptionType.connectionError:
        // Check if it's a SocketException (no internet)
        if (error.error is SocketException) {
          return SearchNetworkException(originalError: error);
        }
        return SearchNetworkException(originalError: error);

      case DioExceptionType.badCertificate:
        return const SearchUnknownException(
          message: 'SSL certificate error',
          userMessage: 'Security certificate error. Please contact support.',
        );

      case DioExceptionType.unknown:
        // Check if underlying error is SocketException
        if (error.error is SocketException) {
          return SearchNetworkException(originalError: error);
        }
        return SearchUnknownException(
          message: error.message ?? 'Unknown error occurred',
          originalError: error,
        );
    }
  }

  /// Map HTTP status code errors to specific exceptions
  static SearchException _mapHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return SearchValidationException(
          message: 'Bad request',
          statusCode: statusCode,
          userMessage:
              _extractErrorMessage(data) ??
              'Invalid request. Please check your input.',
          validationErrors: _extractValidationErrors(data),
          originalError: error,
        );

      case 401:
        return SearchUnauthorizedException(originalError: error);

      case 403:
        return const SearchValidationException(
          message: 'Forbidden',
          statusCode: 403,
          userMessage: 'You do not have permission to perform this action.',
        );

      case 404:
        return SearchNotFoundException(
          resourceType: _extractResourceType(error.requestOptions.path),
          originalError: error,
        );

      case 422:
        return SearchValidationException(
          message: 'Validation failed',
          statusCode: statusCode,
          userMessage:
              _extractErrorMessage(data) ??
              'Validation failed. Please check your input.',
          validationErrors: _extractValidationErrors(data),
          originalError: error,
        );

      case 429:
        return const SearchValidationException(
          message: 'Too many requests',
          statusCode: 429,
          userMessage: 'Too many requests. Please wait a moment and try again.',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return SearchServerException(
          statusCode: statusCode,
          originalError: error,
        );

      default:
        if (statusCode != null && statusCode >= 500) {
          return SearchServerException(
            statusCode: statusCode,
            originalError: error,
          );
        } else if (statusCode != null && statusCode >= 400) {
          return SearchValidationException(
            message: 'Client error',
            statusCode: statusCode,
            userMessage:
                _extractErrorMessage(data) ??
                'An error occurred. Please try again.',
            originalError: error,
          );
        }

        return SearchUnknownException(
          message: 'HTTP error ${statusCode ?? "unknown"}',
          userMessage: 'An unexpected error occurred. Please try again.',
          originalError: error,
        );
    }
  }

  /// Extract error message from response data
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      // Try common error message fields
      if (data['message'] is String) return data['message'] as String;
      if (data['error'] is String) return data['error'] as String;
      if (data['detail'] is String) return data['detail'] as String;

      // Nested error object
      if (data['error'] is Map) {
        final errorObj = data['error'] as Map;
        if (errorObj['message'] is String) {
          return errorObj['message'] as String;
        }
      }
    }

    return null;
  }

  /// Extract validation errors from response data
  static Map<String, dynamic>? _extractValidationErrors(dynamic data) {
    if (data is Map) {
      if (data['errors'] is Map) {
        return data['errors'] as Map<String, dynamic>;
      }
      if (data['validation_errors'] is Map) {
        return data['validation_errors'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  /// Extract resource type from request path
  static String? _extractResourceType(String path) {
    if (path.contains('/search-sessions/')) {
      return 'search session';
    } else if (path.contains('/recommendations/')) {
      return 'recommendation';
    }
    return null;
  }

  /// Convert any exception to SearchException
  static SearchException mapException(Object error, [StackTrace? stackTrace]) {
    if (error is SearchException) {
      return error;
    }

    if (error is DioException) {
      return mapDioException(error);
    }

    if (error is SocketException) {
      return SearchNetworkException(originalError: error);
    }

    if (error is FormatException) {
      return SearchParseException(originalError: error);
    }

    return SearchUnknownException(
      message: error.toString(),
      originalError: error,
    );
  }
}
