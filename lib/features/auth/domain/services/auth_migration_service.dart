import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/constants/storage_keys.dart';

/// Service to migrate auth data from SharedPreferences to FlutterSecureStorage
///
/// This migration is necessary when upgrading from versions that stored
/// authentication tokens in plain text (SharedPreferences) to versions that
/// use encrypted storage (FlutterSecureStorage).
class AuthMigrationService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _storage;

  static const String _migrationCompleteKey = 'auth_migration_complete_v1';

  // Legacy keys from SharedPreferences (before secure storage migration)
  static const String _legacyTokenKey = 'auth_token';
  static const String _legacyTokenTypeKey = 'token_type';
  static const String _legacyUserKey = 'user';

  AuthMigrationService(this._prefs, this._storage);

  /// Migrate auth data from SharedPreferences to FlutterSecureStorage if needed
  ///
  /// This method is idempotent - it can be safely called multiple times.
  /// Once migration is complete, subsequent calls will return immediately.
  Future<void> migrateIfNeeded() async {
    // Check if migration already completed
    final migrationComplete = _prefs.getBool(_migrationCompleteKey) ?? false;
    if (migrationComplete) {
      debugPrint('Auth migration already complete, skipping');
      return;
    }

    try {
      // Check if legacy data exists
      final legacyToken = _prefs.getString(_legacyTokenKey);
      final legacyTokenType = _prefs.getString(_legacyTokenTypeKey);
      final legacyUser = _prefs.getString(_legacyUserKey);

      if (legacyToken != null && legacyTokenType != null) {
        debugPrint('Found legacy auth data, migrating to secure storage...');

        // Migrate to secure storage using current keys
        await _storage.write(key: AuthStorageKeys.token, value: legacyToken);
        await _storage.write(
          key: AuthStorageKeys.tokenType,
          value: legacyTokenType,
        );

        if (legacyUser != null) {
          await _storage.write(key: AuthStorageKeys.user, value: legacyUser);
        }

        // Remove legacy data from SharedPreferences
        await _prefs.remove(_legacyTokenKey);
        await _prefs.remove(_legacyTokenTypeKey);
        if (legacyUser != null) {
          await _prefs.remove(_legacyUserKey);
        }

        debugPrint('✅ Auth migration completed successfully');
      } else {
        debugPrint('No legacy auth data found, skipping migration');
      }

      // Mark migration as complete
      await _prefs.setBool(_migrationCompleteKey, true);
    } catch (e) {
      debugPrint('⚠️ Auth migration failed: $e');
      // Don't mark as complete if migration failed
      // Will retry on next app launch
    }
  }

  /// Check if migration has been completed
  ///
  /// Useful for testing or debugging purposes.
  Future<bool> isMigrationComplete() async {
    return _prefs.getBool(_migrationCompleteKey) ?? false;
  }

  /// Reset migration state (for testing purposes only)
  ///
  /// This method should only be used in test environments to reset
  /// the migration state and allow re-running migrations.
  @visibleForTesting
  Future<void> resetMigrationState() async {
    await _prefs.remove(_migrationCompleteKey);
  }
}
