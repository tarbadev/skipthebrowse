import 'package:dio/dio.dart';
import 'package:skipthebrowse/core/config/env_config.dart';

/// Factory for creating configured Dio instances
///
/// Centralizes HTTP client configuration to eliminate duplication across features.
class DioFactory {
  /// Creates base Dio options used by all instances
  static BaseOptions createBaseOptions() {
    return BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  /// Creates a LogInterceptor with standard configuration
  static LogInterceptor createLogInterceptor() {
    return LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    );
  }

  /// Creates a basic Dio instance with logging
  ///
  /// Use this for creating instances that don't need authentication.
  static Dio createBasicDio() {
    final dio = Dio(createBaseOptions());
    dio.interceptors.add(createLogInterceptor());
    return dio;
  }

  /// Creates a Dio instance with custom interceptors
  ///
  /// Use this when you need to add specific interceptors (e.g., AuthInterceptor).
  static Dio createDioWithInterceptors(List<Interceptor> interceptors) {
    final dio = Dio(createBaseOptions());

    // Add custom interceptors first (e.g., auth)
    dio.interceptors.addAll(interceptors);

    // Add logging last to log the final request/response
    dio.interceptors.add(createLogInterceptor());

    return dio;
  }
}
