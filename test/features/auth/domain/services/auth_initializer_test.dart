import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_session.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_token.dart';
import 'package:skipthebrowse/features/auth/domain/entities/user.dart';
import 'package:skipthebrowse/features/auth/domain/repositories/auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/services/auth_initializer.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthInitializer authInitializer;

  setUp(() {
    mockRepository = MockAuthRepository();
    authInitializer = AuthInitializer(mockRepository);
  });

  group('AuthInitializer - initialize', () {
    test('should do nothing when existing session exists', () async {
      const existingSession = AuthSession(
        user: User(
          id: 'user-123',
          username: 'han-solo-4723',
          isAnonymous: true,
        ),
        token: AuthToken(accessToken: 'test-token', tokenType: 'bearer'),
      );

      when(
        () => mockRepository.getSession(),
      ).thenAnswer((_) async => existingSession);

      await authInitializer.initialize();

      verify(() => mockRepository.getSession()).called(1);
      verifyNever(() => mockRepository.createAnonymousUser(any()));
    });

    test('should create anonymous user when no session exists', () async {
      const newSession = AuthSession(
        user: User(id: 'user-456', username: 'yoda-9876', isAnonymous: true),
        token: AuthToken(accessToken: 'new-token', tokenType: 'bearer'),
      );

      when(() => mockRepository.getSession()).thenAnswer((_) async => null);
      when(
        () => mockRepository.createAnonymousUser(any()),
      ).thenAnswer((_) async => newSession);

      await authInitializer.initialize();

      verify(() => mockRepository.getSession()).called(1);
      verify(() => mockRepository.createAnonymousUser(any())).called(1);
    });

    test('should generate movie-themed username', () async {
      const newSession = AuthSession(
        user: User(id: 'user-789', username: 'test-user', isAnonymous: true),
        token: AuthToken(accessToken: 'token', tokenType: 'bearer'),
      );

      when(() => mockRepository.getSession()).thenAnswer((_) async => null);
      when(
        () => mockRepository.createAnonymousUser(any()),
      ).thenAnswer((_) async => newSession);

      await authInitializer.initialize();

      final captured =
          verify(
                () => mockRepository.createAnonymousUser(captureAny()),
              ).captured.single
              as String;

      // Verify username format: character-name-####
      expect(captured, matches(RegExp(r'^[\w-]+-\d{4}$')));

      // Verify it contains a hyphen and 4-digit suffix
      final parts = captured.split('-');
      expect(parts.length, greaterThanOrEqualTo(2));
      expect(parts.last, matches(RegExp(r'^\d{4}$')));
    });

    test('should handle error when creating anonymous user fails', () async {
      when(() => mockRepository.getSession()).thenAnswer((_) async => null);
      when(
        () => mockRepository.createAnonymousUser(any()),
      ).thenThrow(Exception('API error'));

      expect(() => authInitializer.initialize(), throwsA(isA<Exception>()));
    });
  });
}
