import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/auth/data/models/auth_response_dto.dart';
import 'package:skipthebrowse/features/auth/data/models/create_anonymous_user_request.dart';
import 'package:skipthebrowse/features/auth/data/models/register_user_request.dart';
import 'package:skipthebrowse/features/auth/data/models/login_request.dart';
import 'package:skipthebrowse/features/auth/data/models/merge_account_request.dart';
import 'package:skipthebrowse/features/auth/data/models/user_dto.dart';
import 'package:skipthebrowse/features/auth/data/repositories/api_auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_session.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_token.dart';
import 'package:skipthebrowse/features/auth/domain/entities/user.dart';
import 'package:skipthebrowse/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';

class MockRestClient extends Mock implements RestClient {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockRestClient mockRestClient;
  late MockFlutterSecureStorage mockStorage;
  late ApiAuthRepository repository;

  setUp(() {
    mockRestClient = MockRestClient();
    mockStorage = MockFlutterSecureStorage();
    repository = ApiAuthRepository(mockRestClient, mockStorage);

    registerFallbackValue(CreateAnonymousUserRequest(username: 'test'));
    registerFallbackValue(
      const RegisterUserRequest(
        email: 'test@example.com',
        password: 'Test123!',
        username: 'test-user',
      ),
    );
    registerFallbackValue(
      const LoginRequest(email: 'test@example.com', password: 'Test123!'),
    );
    registerFallbackValue(
      const MergeAccountRequest(
        email: 'test@example.com',
        password: 'Test123!',
      ),
    );
  });

  group('ApiAuthRepository - createAnonymousUser', () {
    test('should create anonymous user and save session', () async {
      const username = 'han-solo-4723';
      final authResponseDto = AuthResponseDto(
        accessToken: 'test-token',
        tokenType: 'bearer',
        user: UserDto(id: 'user-123', username: username, isAnonymous: true),
      );

      when(
        () => mockRestClient.createAnonymousUser(any()),
      ).thenAnswer((_) async => authResponseDto);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});

      final session = await repository.createAnonymousUser(username);

      expect(session.user.id, 'user-123');
      expect(session.user.username, username);
      expect(session.user.isAnonymous, true);
      expect(session.token.accessToken, 'test-token');
      expect(session.token.tokenType, 'bearer');

      verify(() => mockRestClient.createAnonymousUser(any())).called(1);
      verify(
        () => mockStorage.write(key: 'auth_token', value: 'test-token'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'token_type', value: 'bearer'),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'user',
          value: any(named: 'value'),
        ),
      ).called(1);
    });
  });

  group('ApiAuthRepository - saveSession', () {
    test('should save auth session to SecureStorage', () async {
      const session = AuthSession(
        user: User(
          id: 'user-123',
          username: 'han-solo-4723',
          email: 'han@rebellion.org',
          isAnonymous: false,
        ),
        token: AuthToken(accessToken: 'test-token', tokenType: 'bearer'),
      );

      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});

      await repository.saveSession(session);

      verify(
        () => mockStorage.write(key: 'auth_token', value: 'test-token'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'token_type', value: 'bearer'),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'user',
          value: any(named: 'value'),
        ),
      ).called(1);
    });
  });

  group('ApiAuthRepository - getSession', () {
    test('should retrieve auth session from SecureStorage', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'test-token');
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => 'bearer');
      when(() => mockStorage.read(key: 'user')).thenAnswer(
        (_) async =>
            '{"id":"user-123","username":"han-solo-4723","email":"han@rebellion.org","is_anonymous":false}',
      );

      final session = await repository.getSession();

      expect(session, isNotNull);
      expect(session!.user.id, 'user-123');
      expect(session.user.username, 'han-solo-4723');
      expect(session.user.email, 'han@rebellion.org');
      expect(session.user.isAnonymous, false);
      expect(session.token.accessToken, 'test-token');
      expect(session.token.tokenType, 'bearer');
    });

    test('should return null when no token is stored', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      final session = await repository.getSession();

      expect(session, isNull);
    });
  });

  group('ApiAuthRepository - clearSession', () {
    test('should remove all auth data from SecureStorage', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      await repository.clearSession();

      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'token_type')).called(1);
      verify(() => mockStorage.delete(key: 'user')).called(1);
    });
  });

  group('ApiAuthRepository - registerUser', () {
    test('should register user and save session', () async {
      const email = 'luke@skywalker.com';
      const password = 'UseTheForce123!';
      const username = 'luke-skywalker-42';

      final authResponseDto = AuthResponseDto(
        accessToken: 'new-token',
        tokenType: 'bearer',
        user: UserDto(
          id: 'user-456',
          username: username,
          email: email,
          isAnonymous: false,
        ),
      );

      when(
        () => mockRestClient.registerUser(any()),
      ).thenAnswer((_) async => authResponseDto);
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});

      final session = await repository.registerUser(
        email: email,
        password: password,
        username: username,
      );

      expect(session.user.id, 'user-456');
      expect(session.user.username, username);
      expect(session.user.email, email);
      expect(session.user.isAnonymous, false);
      expect(session.token.accessToken, 'new-token');
      expect(session.token.tokenType, 'bearer');

      verify(() => mockRestClient.registerUser(any())).called(1);
      verify(
        () => mockStorage.write(key: 'auth_token', value: 'new-token'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'token_type', value: 'bearer'),
      ).called(1);
      verify(
        () => mockStorage.write(
          key: 'user',
          value: any(named: 'value'),
        ),
      ).called(1);
    });
  });

  group('ApiAuthRepository - Error Handling', () {
    test(
      'should throw AuthStorageException when storage write fails',
      () async {
        const session = AuthSession(
          user: User(id: 'user-123', username: 'han-solo', isAnonymous: true),
          token: AuthToken(accessToken: 'test-token', tokenType: 'bearer'),
        );

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenThrow(
          PlatformException(code: 'write_failed', message: 'Storage full'),
        );

        expect(
          () => repository.saveSession(session),
          throwsA(isA<AuthStorageException>()),
        );
      },
    );

    test('should return null when storage read fails', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'read_failed'));

      final session = await repository.getSession();
      expect(session, isNull);
    });

    test('should return null when token read fails', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenThrow(PlatformException(code: 'read_failed'));

      final token = await repository.getToken();
      expect(token, isNull);
    });

    test('should handle corrupted JSON in user data', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'token');
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => 'bearer');
      when(
        () => mockStorage.read(key: 'user'),
      ).thenAnswer((_) async => '{"id":"123","username":'); // Corrupted JSON
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      final session = await repository.getSession();
      expect(session, isNull);

      // Verify corrupted data was cleared
      verify(() => mockStorage.delete(key: 'user')).called(1);
    });

    test('should handle missing required fields in user data', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'token');
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => 'bearer');
      when(
        () => mockStorage.read(key: 'user'),
      ).thenAnswer((_) async => '{"username":"han-solo"}'); // Missing 'id'
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      final session = await repository.getSession();
      expect(session, isNull);

      verify(() => mockStorage.delete(key: 'user')).called(1);
    });

    test('should handle wrong types in user data', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'token');
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => 'bearer');
      when(() => mockStorage.read(key: 'user')).thenAnswer(
        (_) async =>
            '{"id":123,"username":"han","is_anonymous":false}', // id is int
      );
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      final session = await repository.getSession();
      expect(session, isNull);

      verify(() => mockStorage.delete(key: 'user')).called(1);
    });

    test('should handle non-object JSON in user data', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'token');
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => 'bearer');
      when(
        () => mockStorage.read(key: 'user'),
      ).thenAnswer((_) async => '["not", "an", "object"]'); // Array not object
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      final session = await repository.getSession();
      expect(session, isNull);

      verify(() => mockStorage.delete(key: 'user')).called(1);
    });

    test('should not throw when clearSession fails', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'delete_failed'));

      // Should not throw
      await expectLater(repository.clearSession(), completes);
    });

    test('should return null when getUser storage read fails', () async {
      when(
        () => mockStorage.read(key: 'user'),
      ).thenThrow(PlatformException(code: 'read_failed'));

      final user = await repository.getUser();
      expect(user, isNull);
    });

    test('should clear corrupted data even if delete fails', () async {
      when(
        () => mockStorage.read(key: 'user'),
      ).thenAnswer((_) async => 'invalid json');
      when(
        () => mockStorage.delete(key: 'user'),
      ).thenThrow(PlatformException(code: 'delete_failed'));

      // Should not throw, just return null
      final user = await repository.getUser();
      expect(user, isNull);

      // Attempted to delete
      verify(() => mockStorage.delete(key: 'user')).called(1);
    });
  });
}
