import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/auth/data/models/login_request.dart';

void main() {
  group('LoginRequest', () {
    test('should serialize to JSON correctly', () {
      const request = LoginRequest(
        email: 'test@example.com',
        password: 'SecurePass123!',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'SecurePass123!');
    });

    test('should create instance with all required fields', () {
      const request = LoginRequest(
        email: 'obi-wan@jedi.com',
        password: 'HelloThere123!',
      );

      expect(request.email, 'obi-wan@jedi.com');
      expect(request.password, 'HelloThere123!');
    });
  });
}
