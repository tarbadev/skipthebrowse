import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_session.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_token.dart';
import 'package:skipthebrowse/features/auth/domain/entities/user.dart';
import 'package:skipthebrowse/features/auth/domain/repositories/auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/state/auth_notifier.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('AuthNotifier - initialization', () {
    test(
      'should initialize with loading state then load existing session',
      () async {
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

        final notifier = AuthNotifier(mockRepository);

        // Initial state should be loading
        expect(notifier.state, isA<AsyncLoading>());

        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));

        // Should have loaded the existing session
        expect(notifier.state.value, existingSession);
        expect(notifier.isAuthenticated, true);
        expect(notifier.currentUser, existingSession.user);
        expect(notifier.token, 'test-token');
        expect(notifier.authorizationHeader, 'bearer test-token');

        verify(() => mockRepository.getSession()).called(1);
      },
    );

    test(
      'should initialize with null session when no session exists',
      () async {
        when(() => mockRepository.getSession()).thenAnswer((_) async => null);

        final notifier = AuthNotifier(mockRepository);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(notifier.state.value, isNull);
        expect(notifier.isAuthenticated, false);
        expect(notifier.currentUser, isNull);
        expect(notifier.token, isNull);

        verify(() => mockRepository.getSession()).called(1);
      },
    );

    test('should handle error during initialization', () async {
      when(
        () => mockRepository.getSession(),
      ).thenThrow(Exception('Storage error'));

      final notifier = AuthNotifier(mockRepository);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, isA<AsyncError>());
      expect(notifier.state.hasError, true);
    });
  });

  group('AuthNotifier - createAnonymousUser', () {
    test('should create anonymous user and update state', () async {
      const username = 'yoda-9876';
      const session = AuthSession(
        user: User(id: 'user-456', username: username, isAnonymous: true),
        token: AuthToken(accessToken: 'new-token', tokenType: 'bearer'),
      );

      when(() => mockRepository.getSession()).thenAnswer((_) async => null);
      when(
        () => mockRepository.createAnonymousUser(username),
      ).thenAnswer((_) async => session);

      final notifier = AuthNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.createAnonymousUser(username);

      expect(notifier.state.value, session);
      expect(notifier.isAuthenticated, true);
      expect(notifier.currentUser?.username, username);

      verify(() => mockRepository.createAnonymousUser(username)).called(1);
    });

    test('should handle error when creating anonymous user fails', () async {
      const username = 'invalid-user';

      when(() => mockRepository.getSession()).thenAnswer((_) async => null);
      when(
        () => mockRepository.createAnonymousUser(username),
      ).thenThrow(Exception('API error'));

      final notifier = AuthNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.createAnonymousUser(username);

      expect(notifier.state, isA<AsyncError>());
      expect(notifier.state.hasError, true);
    });
  });

  group('AuthNotifier - logout', () {
    test('should clear session and update state', () async {
      const initialSession = AuthSession(
        user: User(
          id: 'user-123',
          username: 'han-solo-4723',
          isAnonymous: true,
        ),
        token: AuthToken(accessToken: 'test-token', tokenType: 'bearer'),
      );

      when(
        () => mockRepository.getSession(),
      ).thenAnswer((_) async => initialSession);
      when(() => mockRepository.clearSession()).thenAnswer((_) async {});

      final notifier = AuthNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.isAuthenticated, true);

      await notifier.logout();

      expect(notifier.state.value, isNull);
      expect(notifier.isAuthenticated, false);
      expect(notifier.currentUser, isNull);

      verify(() => mockRepository.clearSession()).called(1);
    });

    test('should handle error when logout fails', () async {
      const initialSession = AuthSession(
        user: User(
          id: 'user-123',
          username: 'han-solo-4723',
          isAnonymous: true,
        ),
        token: AuthToken(accessToken: 'test-token', tokenType: 'bearer'),
      );

      when(
        () => mockRepository.getSession(),
      ).thenAnswer((_) async => initialSession);
      when(
        () => mockRepository.clearSession(),
      ).thenThrow(Exception('Storage error'));

      final notifier = AuthNotifier(mockRepository);
      await Future.delayed(const Duration(milliseconds: 100));

      await notifier.logout();

      expect(notifier.state, isA<AsyncError>());
      expect(notifier.state.hasError, true);
    });
  });
}
