import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/auth/domain/services/auth_migration_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockFlutterSecureStorage mockStorage;
  late AuthMigrationService migrationService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockStorage = MockFlutterSecureStorage();
    migrationService = AuthMigrationService(mockPrefs, mockStorage);
  });

  group('AuthMigrationService - migrateIfNeeded', () {
    test(
      'should migrate auth data from SharedPreferences to FlutterSecureStorage',
      () async {
        // Setup legacy data
        when(
          () => mockPrefs.getBool('auth_migration_complete_v1'),
        ).thenReturn(false);
        when(
          () => mockPrefs.getString('auth_token'),
        ).thenReturn('legacy-token');
        when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
        when(() => mockPrefs.getString('user')).thenReturn(
          '{"id":"user-123","username":"han-solo","email":"han@rebellion.org","is_anonymous":false}',
        );

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});
        when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
        when(
          () => mockPrefs.setBool(any(), any()),
        ).thenAnswer((_) async => true);

        await migrationService.migrateIfNeeded();

        // Verify data migrated to secure storage
        verify(
          () => mockStorage.write(key: 'auth_token', value: 'legacy-token'),
        ).called(1);
        verify(
          () => mockStorage.write(key: 'token_type', value: 'bearer'),
        ).called(1);
        verify(
          () => mockStorage.write(
            key: 'user',
            value:
                '{"id":"user-123","username":"han-solo","email":"han@rebellion.org","is_anonymous":false}',
          ),
        ).called(1);

        // Verify legacy data removed
        verify(() => mockPrefs.remove('auth_token')).called(1);
        verify(() => mockPrefs.remove('token_type')).called(1);
        verify(() => mockPrefs.remove('user')).called(1);

        // Verify migration marked complete
        verify(
          () => mockPrefs.setBool('auth_migration_complete_v1', true),
        ).called(1);
      },
    );

    test('should skip migration if already completed', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(true);

      await migrationService.migrateIfNeeded();

      // Should not access storage or preferences
      verifyNever(() => mockPrefs.getString(any()));
      verifyNever(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );
      verifyNever(() => mockPrefs.remove(any()));
    });

    test('should skip migration if no legacy data exists', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(false);
      when(() => mockPrefs.getString('auth_token')).thenReturn(null);
      when(() => mockPrefs.getString('token_type')).thenReturn(null);
      when(() => mockPrefs.getString('user')).thenReturn(null);
      when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

      await migrationService.migrateIfNeeded();

      // Should not write to secure storage
      verifyNever(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      );

      // Should still mark migration as complete
      verify(
        () => mockPrefs.setBool('auth_migration_complete_v1', true),
      ).called(1);
    });

    test(
      'should skip migration if only token exists without token type',
      () async {
        when(
          () => mockPrefs.getBool('auth_migration_complete_v1'),
        ).thenReturn(false);
        when(
          () => mockPrefs.getString('auth_token'),
        ).thenReturn('legacy-token');
        when(() => mockPrefs.getString('token_type')).thenReturn(null);
        when(
          () => mockPrefs.setBool(any(), any()),
        ).thenAnswer((_) async => true);

        await migrationService.migrateIfNeeded();

        // Should not write to secure storage (missing token type)
        verifyNever(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );

        // Should still mark migration as complete
        verify(
          () => mockPrefs.setBool('auth_migration_complete_v1', true),
        ).called(1);
      },
    );

    test('should migrate without user data if user is null', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(false);
      when(() => mockPrefs.getString('auth_token')).thenReturn('legacy-token');
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
      when(() => mockPrefs.getString('user')).thenReturn(null);

      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});
      when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
      when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

      await migrationService.migrateIfNeeded();

      // Verify token data migrated
      verify(
        () => mockStorage.write(key: 'auth_token', value: 'legacy-token'),
      ).called(1);
      verify(
        () => mockStorage.write(key: 'token_type', value: 'bearer'),
      ).called(1);

      // Verify user data not written (was null)
      verifyNever(
        () => mockStorage.write(
          key: 'user',
          value: any(named: 'value'),
        ),
      );

      // Verify only token keys removed (user was null)
      verify(() => mockPrefs.remove('auth_token')).called(1);
      verify(() => mockPrefs.remove('token_type')).called(1);
      verifyNever(() => mockPrefs.remove('user'));

      // Verify migration marked complete
      verify(
        () => mockPrefs.setBool('auth_migration_complete_v1', true),
      ).called(1);
    });

    test('should not mark migration as complete if it fails', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(false);
      when(() => mockPrefs.getString('auth_token')).thenReturn('legacy-token');
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(PlatformException(code: 'write_failed'));

      // Should not throw
      await migrationService.migrateIfNeeded();

      // Should not mark as complete if migration failed
      verifyNever(() => mockPrefs.setBool('auth_migration_complete_v1', true));
    });

    test(
      'should handle errors during legacy data removal gracefully',
      () async {
        when(
          () => mockPrefs.getBool('auth_migration_complete_v1'),
        ).thenReturn(false);
        when(
          () => mockPrefs.getString('auth_token'),
        ).thenReturn('legacy-token');
        when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
        when(() => mockPrefs.getString('user')).thenReturn('{"id":"123"}');

        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockPrefs.remove(any()),
        ).thenThrow(Exception('Remove failed'));

        // Should not throw, but also won't mark as complete due to error
        await migrationService.migrateIfNeeded();

        // Verify migration was attempted
        verify(
          () => mockStorage.write(key: 'auth_token', value: 'legacy-token'),
        ).called(1);

        // Should not mark as complete due to error
        verifyNever(
          () => mockPrefs.setBool('auth_migration_complete_v1', true),
        );
      },
    );
  });

  group('AuthMigrationService - isMigrationComplete', () {
    test('should return true when migration is complete', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(true);

      final result = await migrationService.isMigrationComplete();

      expect(result, true);
    });

    test('should return false when migration is not complete', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(false);

      final result = await migrationService.isMigrationComplete();

      expect(result, false);
    });

    test('should return false when migration key is null', () async {
      when(
        () => mockPrefs.getBool('auth_migration_complete_v1'),
      ).thenReturn(null);

      final result = await migrationService.isMigrationComplete();

      expect(result, false);
    });
  });

  group('AuthMigrationService - resetMigrationState', () {
    test('should remove migration complete key', () async {
      when(
        () => mockPrefs.remove('auth_migration_complete_v1'),
      ).thenAnswer((_) async => true);

      await migrationService.resetMigrationState();

      verify(() => mockPrefs.remove('auth_migration_complete_v1')).called(1);
    });
  });
}
