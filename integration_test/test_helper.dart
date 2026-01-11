import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/core/config/env_config.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';
import 'package:skipthebrowse/features/auth/data/repositories/api_auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/services/auth_initializer.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import 'package:skipthebrowse/main.dart';

Future<void> pumpSkipTheBrowse(WidgetTester tester) async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Clear any cached auth tokens to ensure fresh anonymous user creation
  await sharedPreferences.clear();

  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // We can't easily pass a Ref here in the helper,
  // but the interceptor now handles optional Ref gracefully.
  dio.interceptors.add(AuthInterceptor(sharedPreferences));

  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ),
  );

  final restClient = RestClient(dio);
  final authRepository = ApiAuthRepository(restClient, sharedPreferences);
  final authInitializer = AuthInitializer(authRepository);
  await authInitializer.initialize();

  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        dioProvider.overrideWithValue(dio),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const SkipTheBrowse(),
    ),
  );
  await tester.pumpAndSettle();
}
