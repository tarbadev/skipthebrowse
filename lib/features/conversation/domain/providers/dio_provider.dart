import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/config/env_config.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';
import 'conversation_providers.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Add auth interceptor first to add Authorization header
  final prefs = ref.watch(sharedPreferencesProvider);
  dio.interceptors.add(AuthInterceptor(prefs));

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
