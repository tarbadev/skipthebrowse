import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/auth_providers.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences prefs;
  final Ref? ref;

  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';

  AuthInterceptor(this.prefs, [this.ref]);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = prefs.getString(_tokenKey);
    final tokenType = prefs.getString(_tokenTypeKey);

    if (accessToken != null && tokenType != null) {
      final capitalizedTokenType =
          tokenType[0].toUpperCase() + tokenType.substring(1);
      options.headers['Authorization'] = '$capitalizedTokenType $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final authState = ref?.read(authStateProvider);
      final isAnonymous = authState?.valueOrNull?.user.isAnonymous ?? true;

      await Sentry.captureException(
        err,
        stackTrace: err.stackTrace,
        withScope: (scope) {
          scope.setTag('auth_error', '401_unauthorized');
          scope.setContexts('user_auth', {
            'is_anonymous': isAnonymous,
            'has_token': prefs.getString(_tokenKey) != null,
          });
        },
      );

      if (isAnonymous && ref != null) {
        try {
          // Generate a VALID username if the current one is missing or invalid
          // Backend expects: lowercase, numbers, and hyphens ONLY.
          final currentUsername = authState?.valueOrNull?.user.username;
          final username =
              (currentUsername != null && currentUsername.isNotEmpty)
              ? currentUsername
              : _generateValidUsername();

          await ref!
              .read(authStateProvider.notifier)
              .createAnonymousUser(username);

          final response = await _retry(err.requestOptions);
          return handler.resolve(response);
        } catch (e, stackTrace) {
          await Sentry.captureException(
            e,
            stackTrace: stackTrace,
            withScope: (scope) =>
                scope.setTag('auth_error', 'token_regeneration_failed'),
          );

          return handler.next(
            DioException(
              requestOptions: err.requestOptions,
              error: 'Authentication failed. Please restart the app.',
              type: DioExceptionType.unknown,
            ),
          );
        }
      } else {
        return handler.next(
          DioException(
            requestOptions: err.requestOptions,
            error: isAnonymous
                ? 'Authentication failed.'
                : 'Your session has expired. Please login again.',
            type: DioExceptionType.unknown,
          ),
        );
      }
    }
    super.onError(err, handler);
  }

  String _generateValidUsername() {
    final movieCharacters = [
      'han-solo',
      'luke-skywalker',
      'doc-brown',
      'neo',
      'yoda',
    ];
    final random = Random();
    final character = movieCharacters[random.nextInt(movieCharacters.length)];
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return '$character-$randomSuffix';
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final dio = Dio(BaseOptions(baseUrl: requestOptions.baseUrl));
    final accessToken = prefs.getString(_tokenKey);
    final tokenType = prefs.getString(_tokenTypeKey);

    if (accessToken != null && tokenType != null) {
      final capitalizedTokenType =
          tokenType[0].toUpperCase() + tokenType.substring(1);
      requestOptions.headers['Authorization'] =
          '$capitalizedTokenType $accessToken';
    }

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
}
