import 'dart:convert';
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
    await _storage.delete(key: AuthStorageKeys.token);
    await _storage.delete(key: AuthStorageKeys.tokenType);
    await _storage.delete(key: AuthStorageKeys.user);
  }

  @override
  Future<AuthToken?> getToken() async {
    final accessToken = await _storage.read(key: AuthStorageKeys.token);
    final tokenType = await _storage.read(key: AuthStorageKeys.tokenType);

    if (accessToken == null || tokenType == null) {
      return null;
    }

    return AuthToken(accessToken: accessToken, tokenType: tokenType);
  }

  @override
  Future<User?> getUser() async {
    final userJson = await _storage.read(key: AuthStorageKeys.user);

    if (userJson == null) {
      return null;
    }

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    return User(
      id: userMap['id'] as String,
      username: userMap['username'] as String,
      email: userMap['email'] as String?,
      isAnonymous: userMap['is_anonymous'] as bool,
    );
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
