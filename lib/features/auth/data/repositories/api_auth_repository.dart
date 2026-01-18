import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../conversation/data/repositories/rest_client.dart';
import '../models/create_anonymous_user_request.dart';
import '../models/register_user_request.dart';
import '../models/login_request.dart';
import '../models/merge_account_request.dart';
import '../constants/storage_keys.dart';
import '../../domain/exceptions/auth_exceptions.dart';

class ApiAuthRepository implements AuthRepository {
  final RestClient _restClient;
  final FlutterSecureStorage _storage;

  ApiAuthRepository(this._restClient, this._storage);

  @override
  Future<AuthSession> createAnonymousUser(String username) async {
    final request = CreateAnonymousUserRequest(username: username);
    final response = await _restClient.createAnonymousUser(request);
    final session = response.toEntity();

    await saveSession(session);

    return session;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    try {
      await _storage.write(
        key: AuthStorageKeys.token,
        value: session.token.accessToken,
      );
      await _storage.write(
        key: AuthStorageKeys.tokenType,
        value: session.token.tokenType,
      );
      await _storage.write(
        key: AuthStorageKeys.user,
        value: jsonEncode({
          'id': session.user.id,
          'username': session.user.username,
          'email': session.user.email,
          'is_anonymous': session.user.isAnonymous,
        }),
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to save auth session: ${e.code} - ${e.message}');
      throw AuthStorageException(
        'Failed to save authentication session. Please check device storage and permissions.',
        originalError: e,
      );
    } catch (e) {
      debugPrint('Unexpected error saving auth session: $e');
      throw AuthStorageException(
        'Failed to save authentication session',
        originalError: e,
      );
    }
  }

  @override
  Future<AuthSession?> getSession() async {
    final token = await getToken();
    final user = await getUser();

    if (token == null || user == null) {
      return null;
    }

    return AuthSession(user: user, token: token);
  }

  @override
  Future<void> clearSession() async {
    try {
      await _storage.delete(key: AuthStorageKeys.token);
      await _storage.delete(key: AuthStorageKeys.tokenType);
      await _storage.delete(key: AuthStorageKeys.user);
    } on PlatformException catch (e) {
      // Log but don't throw - clearing session should be best-effort
      debugPrint('Failed to clear auth session: ${e.code} - ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error clearing auth session: $e');
    }
  }

  @override
  Future<AuthToken?> getToken() async {
    try {
      final accessToken = await _storage.read(key: AuthStorageKeys.token);
      final tokenType = await _storage.read(key: AuthStorageKeys.tokenType);

      if (accessToken == null || tokenType == null) {
        return null;
      }

      return AuthToken(accessToken: accessToken, tokenType: tokenType);
    } on PlatformException catch (e) {
      debugPrint('Failed to read auth token: ${e.code} - ${e.message}');
      // For read errors, return null (treat as not authenticated)
      // This allows graceful degradation instead of app crash
      return null;
    } catch (e) {
      debugPrint('Unexpected error reading auth token: $e');
      return null;
    }
  }

  @override
  Future<User?> getUser() async {
    try {
      final userJson = await _storage.read(key: AuthStorageKeys.user);

      if (userJson == null) {
        return null;
      }

      final userMap = jsonDecode(userJson);

      // Validate structure
      if (userMap is! Map<String, dynamic>) {
        debugPrint('User data is not a valid JSON object');
        // Clear corrupted data
        await _storage.delete(key: AuthStorageKeys.user);
        return null;
      }

      // Validate required fields with safe casting
      final id = userMap['id'];
      final username = userMap['username'];
      final isAnonymous = userMap['is_anonymous'];

      if (id is! String || username is! String || isAnonymous is! bool) {
        debugPrint('User data missing required fields or wrong types');
        await _storage.delete(key: AuthStorageKeys.user);
        return null;
      }

      return User(
        id: id,
        username: username,
        email: userMap['email'] as String?,
        isAnonymous: isAnonymous,
      );
    } on FormatException catch (e) {
      debugPrint('Failed to parse user JSON: $e');
      // Clear corrupted data
      try {
        await _storage.delete(key: AuthStorageKeys.user);
      } catch (deleteError) {
        debugPrint('Failed to clear corrupted user data: $deleteError');
      }
      return null;
    } on PlatformException catch (e) {
      debugPrint('Failed to read user from storage: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error reading user: $e');
      return null;
    }
  }

  @override
  Future<AuthSession> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    final request = RegisterUserRequest(
      email: email,
      password: password,
      username: username,
    );
    final response = await _restClient.registerUser(request);
    final session = response.toEntity();

    await saveSession(session);

    return session;
  }

  @override
  Future<AuthSession> loginUser({
    required String email,
    required String password,
  }) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _restClient.loginUser(request);
    final session = response.toEntity();

    await saveSession(session);

    return session;
  }

  @override
  Future<AuthSession> mergeAnonymousAccount({
    required String email,
    required String password,
  }) async {
    final request = MergeAccountRequest(email: email, password: password);
    final response = await _restClient.mergeAnonymousAccount(request);
    final session = response.toEntity();

    await saveSession(session);

    return session;
  }
}
