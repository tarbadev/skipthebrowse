import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skipthebrowse/core/network/dio_provider.dart';
import 'package:skipthebrowse/features/auth/data/repositories/api_auth_repository.dart';
import 'package:skipthebrowse/features/auth/data/storage/auth_storage.dart';
import 'package:skipthebrowse/features/auth/domain/repositories/auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/state/auth_notifier.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import '../entities/auth_session.dart';

final authStorageProvider = Provider<AuthStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  // Disable secure storage in certain environments to avoid entitlement/keyring issues:
  // 1. Debug mode on macOS (avoids keychain entitlement requirement without dev account)
  // 2. Linux integration tests/CI (avoids headless Libsecret errors)
  final bool isMacDebug =
      kDebugMode && defaultTargetPlatform == TargetPlatform.macOS;
  final bool isLinuxCI =
      !kReleaseMode && defaultTargetPlatform == TargetPlatform.linux;

  if (isMacDebug || isLinuxCI) {
    return InsecureAuthStorage(prefs);
  }

  return SecureAuthStorage(const FlutterSecureStorage());
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(baseDioProvider);
  final restClient = RestClient(dio, baseUrl: dio.options.baseUrl);
  final storage = ref.watch(authStorageProvider);

  return ApiAuthRepository(restClient, storage);
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthSession?>>((ref) {
      return AuthNotifier(ref.watch(authRepositoryProvider));
    });
