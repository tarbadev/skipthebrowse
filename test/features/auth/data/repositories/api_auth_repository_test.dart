import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/auth/data/models/auth_response_dto.dart';
import 'package:skipthebrowse/features/auth/data/models/create_anonymous_user_request.dart';
import 'package:skipthebrowse/features/auth/data/models/user_dto.dart';
import 'package:skipthebrowse/features/auth/data/repositories/api_auth_repository.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_session.dart';
import 'package:skipthebrowse/features/auth/domain/entities/auth_token.dart';
import 'package:skipthebrowse/features/auth/domain/entities/user.dart';
import 'package:skipthebrowse/features/conversation/data/repositories/rest_client.dart';

class MockRestClient extends Mock implements RestClient {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockRestClient mockRestClient;
  late MockSharedPreferences mockPrefs;
  late ApiAuthRepository repository;

  setUp(() {
    mockRestClient = MockRestClient();
    mockPrefs = MockSharedPreferences();
    repository = ApiAuthRepository(mockRestClient, mockPrefs);

    registerFallbackValue(CreateAnonymousUserRequest(username: 'test'));
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
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      final session = await repository.createAnonymousUser(username);

      expect(session.user.id, 'user-123');
      expect(session.user.username, username);
      expect(session.user.isAnonymous, true);
      expect(session.token.accessToken, 'test-token');
      expect(session.token.tokenType, 'bearer');

      verify(() => mockRestClient.createAnonymousUser(any())).called(1);
      verify(() => mockPrefs.setString('auth_token', 'test-token')).called(1);
      verify(() => mockPrefs.setString('token_type', 'bearer')).called(1);
      verify(() => mockPrefs.setString('user', any())).called(1);
    });
  });

  group('ApiAuthRepository - saveSession', () {
    test('should save auth session to SharedPreferences', () async {
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
        () => mockPrefs.setString(any(), any()),
      ).thenAnswer((_) async => true);

      await repository.saveSession(session);

      verify(() => mockPrefs.setString('auth_token', 'test-token')).called(1);
      verify(() => mockPrefs.setString('token_type', 'bearer')).called(1);
      verify(() => mockPrefs.setString('user', any())).called(1);
    });
  });

  group('ApiAuthRepository - getSession', () {
    test('should retrieve auth session from SharedPreferences', () async {
      when(() => mockPrefs.getString('auth_token')).thenReturn('test-token');
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
      when(() => mockPrefs.getString('user')).thenReturn(
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
      when(() => mockPrefs.getString('auth_token')).thenReturn(null);
      when(() => mockPrefs.getString('token_type')).thenReturn(null);
      when(() => mockPrefs.getString('user')).thenReturn(null);

      final session = await repository.getSession();

      expect(session, isNull);
    });
  });

  group('ApiAuthRepository - clearSession', () {
    test('should remove all auth data from SharedPreferences', () async {
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);

      await repository.clearSession();

      verify(() => mockPrefs.remove('auth_token')).called(1);
      verify(() => mockPrefs.remove('token_type')).called(1);
      verify(() => mockPrefs.remove('user')).called(1);
    });
  });

  group('ApiAuthRepository - getToken', () {
    test('should retrieve auth token from SharedPreferences', () async {
      when(() => mockPrefs.getString('auth_token')).thenReturn('test-token');
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');

      final token = await repository.getToken();

      expect(token, isNotNull);
      expect(token!.accessToken, 'test-token');
      expect(token.tokenType, 'bearer');
    });

    test('should return null when no token is stored', () async {
      when(() => mockPrefs.getString('auth_token')).thenReturn(null);
      when(() => mockPrefs.getString('token_type')).thenReturn(null);

      final token = await repository.getToken();

      expect(token, isNull);
    });
  });

  group('ApiAuthRepository - getUser', () {
    test('should retrieve user from SharedPreferences', () async {
      when(() => mockPrefs.getString('user')).thenReturn(
        '{"id":"user-123","username":"han-solo-4723","email":null,"is_anonymous":true}',
      );

      final user = await repository.getUser();

      expect(user, isNotNull);
      expect(user!.id, 'user-123');
      expect(user.username, 'han-solo-4723');
      expect(user.email, null);
      expect(user.isAnonymous, true);
    });

    test('should return null when no user is stored', () async {
      when(() => mockPrefs.getString('user')).thenReturn(null);

      final user = await repository.getUser();

      expect(user, isNull);
    });
  });
}
