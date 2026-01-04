import 'package:flutter_test/flutter_test.dart';
import 'package:skipthebrowse/features/auth/data/models/merge_account_request.dart';

void main() {
  group('MergeAccountRequest', () {
    test('should create request with email and password', () {
      const request = MergeAccountRequest(
        email: 'han@rebellion.org',
        password: 'ShotFirst123!',
      );

      expect(request.email, 'han@rebellion.org');
      expect(request.password, 'ShotFirst123!');
    });

    test('should serialize to JSON correctly', () {
      const request = MergeAccountRequest(
        email: 'test@example.com',
        password: 'SecurePass123!',
      );

      final json = request.toJson();

      expect(json['email'], 'test@example.com');
      expect(json['password'], 'SecurePass123!');
    });
  });
}
