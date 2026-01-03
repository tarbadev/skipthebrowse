import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../conversation/data/repositories/rest_client.dart';
import '../models/create_anonymous_user_request.dart';

class ApiAuthRepository implements AuthRepository {
  final RestClient _restClient;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userKey = 'user';

  ApiAuthRepository(this._restClient, this._prefs);

  @override
  Future<AuthSession> createAnonymousUser(String username) async {
    final request = CreateAnonymousUserRequest(username: username);
    final response = await _restClient.createAnonymousUser(request);
    final session = response.toEntity();

    // Save session to local storage
    await saveSession(session);

    return session;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await _prefs.setString(_tokenKey, session.token.accessToken);
    await _prefs.setString(_tokenTypeKey, session.token.tokenType);
    await _prefs.setString(
      _userKey,
      jsonEncode({
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
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_tokenTypeKey);
    await _prefs.remove(_userKey);
  }

  @override
  Future<AuthToken?> getToken() async {
    final accessToken = _prefs.getString(_tokenKey);
    final tokenType = _prefs.getString(_tokenTypeKey);

    if (accessToken == null || tokenType == null) {
      return null;
    }

    return AuthToken(accessToken: accessToken, tokenType: tokenType);
  }

  @override
  Future<User?> getUser() async {
    final userJson = _prefs.getString(_userKey);

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
}
