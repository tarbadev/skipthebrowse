import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/config/env_config.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:skipthebrowse/features/auth/domain/providers/auth_providers.dart';

/// Base Dio instance without the AuthInterceptor to avoid circular dependencies
final baseDioProvider = Provider<Dio>((ref) {
  return Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    )
    ..interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ),
    );
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add auth interceptor first to add Authorization header
  final storage = ref.watch(authStorageProvider);
  dio.interceptors.add(AuthInterceptor(storage, ref));

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ),
  );

  return dio;
});
