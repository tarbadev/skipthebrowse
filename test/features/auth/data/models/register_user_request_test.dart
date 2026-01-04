import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/auth/data/models/register_user_request.dart';

void main() {
  group('RegisterUserRequest', () {
    test('should serialize to JSON correctly', () {
      const request = RegisterUserRequest(
        email: 'test@example.com',
        password: 'SecurePass123!',
        username: 'test-user-42',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'SecurePass123!');
      expect(json['username'], 'test-user-42');
    });

    test('should create instance with all required fields', () {
      const request = RegisterUserRequest(
        email: 'luke@skywalker.com',
        password: 'UseTheForce123!',
        username: 'luke-skywalker-42',
      );

      expect(request.email, 'luke@skywalker.com');
      expect(request.password, 'UseTheForce123!');
      expect(request.username, 'luke-skywalker-42');
    });
  });
}
