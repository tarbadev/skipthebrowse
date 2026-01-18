import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/auth/domain/providers/auth_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/conversation_providers.dart';
import 'package:skipthebrowse/features/conversation/domain/providers/dio_provider.dart';

import 'helpers/mock_dio_helper.dart';

void main() {
  group('Integration Tests - Auth', () {
    late SharedPreferences sharedPreferences;
    late MockDioHelper mockDioHelper;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      FlutterSecureStorage.setMockInitialValues({});
      mockDioHelper = MockDioHelper();
    });

    tearDown(() {
      container.dispose();
    });

    test('user can register with email and password', () async {
      const userId = 'user-123';
      const username = 'luke-skywalker';
      const email = 'luke@jedi.org';
      const password = 'UseTheForce123!';
      const accessToken = 'test-access-token';

      mockDioHelper.mockRegisterUser(
        userId: userId,
        username: username,
        email: email,
        password: password,
        accessToken: accessToken,
      );

      container = ProviderContainer(
        overrides: [
          baseDioProvider.overrideWithValue(mockDioHelper.dio),
          dioProvider.overrideWithValue(mockDioHelper.dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final authNotifier = container.read(authStateProvider.notifier);

      // Initially, user should not be authenticated
      expect(authNotifier.isAuthenticated, false);
      expect(authNotifier.currentUser, null);

      // Register user
      await authNotifier.registerUser(
        email: email,
        password: password,
        username: username,
      );

      // After registration, user should be authenticated
      expect(authNotifier.isAuthenticated, true);
      expect(authNotifier.currentUser?.id, userId);
      expect(authNotifier.currentUser?.username, username);
      expect(authNotifier.currentUser?.email, email);
      expect(authNotifier.currentUser?.isAnonymous, false);
      expect(authNotifier.token, accessToken);

      // Session should be persisted in SecureStorage
      final storage = container.read(secureStorageProvider);
      expect(await storage.read(key: 'auth_token'), accessToken);
      expect(await storage.read(key: 'token_type'), 'bearer');
      expect(await storage.read(key: 'user'), isNotNull);
    });

    test('user can login with email and password', () async {
      const userId = 'user-456';
      const username = 'han-solo';
      const email = 'han@rebellion.org';
      const password = 'ShotFirst123!';
      const accessToken = 'test-login-token';

      mockDioHelper.mockLoginUser(
        userId: userId,
        username: username,
        email: email,
        password: password,
        accessToken: accessToken,
      );

      container = ProviderContainer(
        overrides: [
          baseDioProvider.overrideWithValue(mockDioHelper.dio),
          dioProvider.overrideWithValue(mockDioHelper.dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final authNotifier = container.read(authStateProvider.notifier);

      // Initially, user should not be authenticated
      expect(authNotifier.isAuthenticated, false);

      // Login user
      await authNotifier.loginUser(email: email, password: password);

      // After login, user should be authenticated
      expect(authNotifier.isAuthenticated, true);
      expect(authNotifier.currentUser?.id, userId);
      expect(authNotifier.currentUser?.username, username);
      expect(authNotifier.currentUser?.email, email);
      expect(authNotifier.currentUser?.isAnonymous, false);
      expect(authNotifier.token, accessToken);

      // Session should be persisted
      final storage = container.read(secureStorageProvider);
      expect(await storage.read(key: 'auth_token'), accessToken);
    });

    test('anonymous user can merge account with email and password', () async {
      const userId = 'user-789';
      const username = 'yoda-1234';
      const anonymousToken = 'anonymous-token';
      const mergedToken = 'merged-token';
      const email = 'yoda@jedi.org';
      const password = 'DoOrDoNot123!';

      // First create anonymous user
      mockDioHelper.mockCreateAnonymousUser(
        userId: userId,
        username: username,
        accessToken: anonymousToken,
      );

      // Then mock merge endpoint
      mockDioHelper.mockMergeAnonymousAccount(
        userId: userId,
        username: username,
        email: email,
        password: password,
        accessToken: mergedToken,
      );

      container = ProviderContainer(
        overrides: [
          baseDioProvider.overrideWithValue(mockDioHelper.dio),
          dioProvider.overrideWithValue(mockDioHelper.dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final authNotifier = container.read(authStateProvider.notifier);

      // Create anonymous user
      await authNotifier.createAnonymousUser(username);

      // Verify anonymous state
      expect(authNotifier.isAuthenticated, true);
      expect(authNotifier.currentUser?.username, username);
      expect(authNotifier.currentUser?.isAnonymous, true);
      expect(authNotifier.currentUser?.email, null);
      expect(authNotifier.token, anonymousToken);

      // Merge account
      await authNotifier.mergeAnonymousAccount(
        email: email,
        password: password,
      );

      // After merge, user should be registered (not anonymous)
      expect(authNotifier.isAuthenticated, true);
      expect(authNotifier.currentUser?.id, userId); // Same user ID
      expect(authNotifier.currentUser?.username, username); // Same username
      expect(authNotifier.currentUser?.email, email); // Email added
      expect(
        authNotifier.currentUser?.isAnonymous,
        false,
      ); // No longer anonymous
      expect(authNotifier.token, mergedToken); // New token

      // Session should be updated
      final storage = container.read(secureStorageProvider);
      expect(await storage.read(key: 'auth_token'), mergedToken);
    });

    test('user can logout and clear session', () async {
      const userId = 'user-999';
      const username = 'obiwan';
      const email = 'obiwan@jedi.org';
      const password = 'HelloThere123!';
      const accessToken = 'test-token';

      mockDioHelper.mockRegisterUser(
        userId: userId,
        username: username,
        email: email,
        password: password,
        accessToken: accessToken,
      );

      container = ProviderContainer(
        overrides: [
          baseDioProvider.overrideWithValue(mockDioHelper.dio),
          dioProvider.overrideWithValue(mockDioHelper.dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final authNotifier = container.read(authStateProvider.notifier);

      // Register and verify authenticated
      await authNotifier.registerUser(
        email: email,
        password: password,
        username: username,
      );
      expect(authNotifier.isAuthenticated, true);

      // Logout
      await authNotifier.logout();

      // After logout, user should not be authenticated
      expect(authNotifier.isAuthenticated, false);
      expect(authNotifier.currentUser, null);
      expect(authNotifier.token, null);

      // Session should be cleared from SecureStorage
      final storage = container.read(secureStorageProvider);
      expect(await storage.read(key: 'auth_token'), null);
      expect(await storage.read(key: 'token_type'), null);
      expect(await storage.read(key: 'user'), null);
    });

    test('session persists across app restarts', () async {
      const userId = 'user-persist';
      const username = 'leia';
      const email = 'leia@rebellion.org';
      const password = 'Alderaan123!';
      const accessToken = 'persistent-token';

      mockDioHelper.mockRegisterUser(
        userId: userId,
        username: username,
        email: email,
        password: password,
        accessToken: accessToken,
      );

      // First container - register user
      container = ProviderContainer(
        overrides: [
          baseDioProvider.overrideWithValue(mockDioHelper.dio),
          dioProvider.overrideWithValue(mockDioHelper.dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final authNotifier1 = container.read(authStateProvider.notifier);
      await authNotifier1.registerUser(
        email: email,
        password: password,
        username: username,
      );
      expect(authNotifier1.isAuthenticated, true);
      container.dispose();

      // Second container - simulate app restart
      final container2 = ProviderContainer(
        overrides: [
          baseDioProvider.overrideWithValue(mockDioHelper.dio),
          dioProvider.overrideWithValue(mockDioHelper.dio),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      final authNotifier2 = container2.read(authStateProvider.notifier);

      // Wait for initialization to complete
      // The notifier starts in loading state, then loads the session
      await Future.delayed(const Duration(milliseconds: 200));

      // Session should be restored from SecureStorage
      expect(authNotifier2.isAuthenticated, true);
      expect(authNotifier2.currentUser?.id, userId);
      expect(authNotifier2.currentUser?.username, username);
      expect(authNotifier2.currentUser?.email, email);
      expect(authNotifier2.token, accessToken);

      container2.dispose();
    });
  });
}
