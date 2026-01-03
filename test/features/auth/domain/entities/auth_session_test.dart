import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_session.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_token.dart';
import 'package:skipthebrowse/features/auth/domain/entities/user.dart';

void main() {
  group('AuthSession', () {
    test('should create AuthSession with user and token', () {
      const user = User(
        id: 'user-123',
        username: 'han-solo-4723',
        isAnonymous: true,
      );

      const token = AuthToken(accessToken: 'test-token', tokenType: 'bearer');

      const session = AuthSession(user: user, token: token);

      expect(session.user, user);
      expect(session.token, token);
    });

    test('should support value equality', () {
      const user = User(
        id: 'user-123',
        username: 'han-solo-4723',
        isAnonymous: true,
      );

      const token = AuthToken(accessToken: 'test-token', tokenType: 'bearer');

      const session1 = AuthSession(user: user, token: token);
      const session2 = AuthSession(user: user, token: token);

      expect(session1, session2);
      expect(session1.hashCode, session2.hashCode);
    });

    test('should not be equal when user differs', () {
      const user1 = User(
        id: 'user-123',
        username: 'han-solo-4723',
        isAnonymous: true,
      );

      const user2 = User(
        id: 'user-456',
        username: 'yoda-9876',
        isAnonymous: true,
      );

      const token = AuthToken(accessToken: 'test-token', tokenType: 'bearer');

      const session1 = AuthSession(user: user1, token: token);
      const session2 = AuthSession(user: user2, token: token);

      expect(session1, isNot(session2));
    });
  });
}
