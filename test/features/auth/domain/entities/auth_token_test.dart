import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_token.dart';

void main() {
  group('AuthToken', () {
    test('should create AuthToken with access token and type', () {
      const token = AuthToken(
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        tokenType: 'bearer',
      );

      expect(token.accessToken, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
      expect(token.tokenType, 'bearer');
    });

    test('should generate correct Authorization header', () {
      const token = AuthToken(
        accessToken: 'test-token-123',
        tokenType: 'bearer',
      );

      expect(token.authorizationHeader, 'bearer test-token-123');
    });

    test('should support value equality', () {
      const token1 = AuthToken(accessToken: 'test-token', tokenType: 'bearer');

      const token2 = AuthToken(accessToken: 'test-token', tokenType: 'bearer');

      expect(token1, token2);
      expect(token1.hashCode, token2.hashCode);
    });

    test('should not be equal when tokens differ', () {
      const token1 = AuthToken(accessToken: 'token-1', tokenType: 'bearer');

      const token2 = AuthToken(accessToken: 'token-2', tokenType: 'bearer');

      expect(token1, isNot(token2));
    });
  });
}
