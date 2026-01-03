import '../entities/auth_session.dart';
import '../entities/auth_token.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Create an anonymous user with the given username
  Future<AuthSession> createAnonymousUser(String username);

  /// Save auth session (token + user) to local storage
  Future<void> saveSession(AuthSession session);

  /// Get saved auth session from local storage
  Future<AuthSession?> getSession();

  /// Clear auth session from local storage
  Future<void> clearSession();

  /// Get the current auth token (if exists)
  Future<AuthToken?> getToken();

  /// Get the current user (if exists)
  Future<User?> getUser();
}
