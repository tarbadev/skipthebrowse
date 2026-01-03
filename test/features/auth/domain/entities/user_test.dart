import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/auth/domain/entities/user.dart';

void main() {
  group('User', () {
    test('should create User with all properties', () {
      const user = User(
        id: 'user-123',
        username: 'han-solo-4723',
        email: 'han@rebellion.org',
        isAnonymous: false,
      );

      expect(user.id, 'user-123');
      expect(user.username, 'han-solo-4723');
      expect(user.email, 'han@rebellion.org');
      expect(user.isAnonymous, false);
    });

    test('should create anonymous User without email', () {
      const user = User(
        id: 'user-456',
        username: 'yoda-9876',
        isAnonymous: true,
      );

      expect(user.id, 'user-456');
      expect(user.username, 'yoda-9876');
      expect(user.email, null);
      expect(user.isAnonymous, true);
    });

    test('should support value equality', () {
      const user1 = User(
        id: 'user-123',
        username: 'han-solo-4723',
        email: 'han@rebellion.org',
        isAnonymous: false,
      );

      const user2 = User(
        id: 'user-123',
        username: 'han-solo-4723',
        email: 'han@rebellion.org',
        isAnonymous: false,
      );

      expect(user1, user2);
      expect(user1.hashCode, user2.hashCode);
    });

    test('should not be equal when properties differ', () {
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

      expect(user1, isNot(user2));
    });
  });
}
