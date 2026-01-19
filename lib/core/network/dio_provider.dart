import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/core/network/dio_factory.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:skipthebrowse/features/auth/domain/providers/auth_providers.dart';

/// Base Dio instance without the AuthInterceptor to avoid circular dependencies
///
/// Use this for API calls that don't require authentication (e.g., login, register).
final baseDioProvider = Provider<Dio>((ref) {
  return DioFactory.createBasicDio();
});

/// Dio instance with AuthInterceptor for authenticated API calls
///
/// Use this for API calls that require authentication.
final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(authStorageProvider);
  final authInterceptor = AuthInterceptor(storage, ref);

  return DioFactory.createDioWithInterceptors([authInterceptor]);
});
