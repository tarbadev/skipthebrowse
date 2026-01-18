import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to validate FlutterSecureStorage availability and functionality
///
/// Checks that secure storage can perform basic read/write operations before
/// the app relies on it. This prevents runtime failures on devices where
/// secure storage is unavailable (e.g., jailbroken devices, permission issues).
class StorageValidator {
  final FlutterSecureStorage _storage;

  static const String _validationKey = '_storage_validation_test';
  static const String _validationValue = 'test_value_skipthebrowse';

  StorageValidator(this._storage);

  /// Validates that secure storage is available and functional
  ///
  /// Returns true if storage can be read from and written to.
  /// Returns false if any storage operation fails.
  ///
  /// This is a non-invasive test that:
  /// 1. Writes a test value to secure storage
  /// 2. Reads it back to verify
  /// 3. Cleans up the test data
  Future<bool> validateStorage() async {
    bool isValid = false;
    bool shouldCleanup = false;

    try {
      // Test write operation
      await _storage.write(key: _validationKey, value: _validationValue);
      shouldCleanup = true;

      // Test read operation
      final readValue = await _storage.read(key: _validationKey);

      // Verify the value matches
      if (readValue != _validationValue) {
        debugPrint(
          '⚠️ Storage validation failed: Read value does not match written value',
        );
        isValid = false;
      } else {
        debugPrint('✅ Secure storage validation passed');
        isValid = true;
      }
    } on PlatformException catch (e) {
      debugPrint(
        '⚠️ Secure storage validation failed: ${e.code} - ${e.message}',
      );
      isValid = false;
    } catch (e) {
      debugPrint('⚠️ Unexpected error during storage validation: $e');
      isValid = false;
    } finally {
      // Always attempt cleanup if we wrote data
      if (shouldCleanup) {
        try {
          await _storage.delete(key: _validationKey);
        } catch (e) {
          debugPrint('⚠️ Failed to clean up validation test data: $e');
          // If cleanup fails, storage is not reliable
          isValid = false;
        }
      }
    }

    return isValid;
  }

  /// Gets a human-readable error message for storage unavailability
  ///
  /// This can be shown to users when storage validation fails.
  String getStorageUnavailableMessage() {
    return 'Secure storage is not available on this device. '
        'Please ensure your device is not jailbroken and that app permissions are granted.';
  }
}
