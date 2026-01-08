import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skipthebrowse/features/auth/data/repositories/api_auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/repositories/auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/state/auth_notifier.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';
import '../entities/auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Use baseDioProvider to avoid circular dependency with AuthInterceptor
  final dio = ref.watch(baseDioProvider);
  final restClient = RestClient(dio, baseUrl: dio.options.baseUrl);
  final prefs = ref.watch(sharedPreferencesProvider);

  return ApiAuthRepository(restClient, prefs);
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthSession?>>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });
