import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/auth/domain/services/storage_validator.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late StorageValidator validator;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    validator = StorageValidator(mockStorage);
  });

  group('StorageValidator - validateStorage', () {
    test('should return true when storage operations succeed', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'test_value_skipthebrowse');
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      final result = await validator.validateStorage();

      expect(result, true);
      verify(
        () => mockStorage.write(
          key: '_storage_validation_test',
          value: any(named: 'value'),
        ),
      ).called(1);
      verify(() => mockStorage.read(key: '_storage_validation_test')).called(1);
      verify(
        () => mockStorage.delete(key: '_storage_validation_test'),
      ).called(1);
    });

    test('should return false when write operation fails', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(PlatformException(code: 'write_failed'));

      final result = await validator.validateStorage();

      expect(result, false);
      verifyNever(() => mockStorage.read(key: any(named: 'key')));
      verifyNever(() => mockStorage.delete(key: any(named: 'key')));
    });

    test('should return false when read operation fails', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'read_failed'));
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      final result = await validator.validateStorage();

      expect(result, false);
      // Should still attempt cleanup even though read failed
      verify(
        () => mockStorage.delete(key: '_storage_validation_test'),
      ).called(1);
    });

    test(
      'should return false when read value does not match written value',
      () async {
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenAnswer((_) async => {});
        when(
          () => mockStorage.read(key: any(named: 'key')),
        ).thenAnswer((_) async => 'wrong_value'); // Different value

        final result = await validator.validateStorage();

        expect(result, false);
        // Still attempt cleanup even if validation fails
        verify(
          () => mockStorage.delete(key: '_storage_validation_test'),
        ).called(1);
      },
    );

    test('should return false when delete operation fails', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'test_value_skipthebrowse');
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenThrow(PlatformException(code: 'delete_failed'));

      final result = await validator.validateStorage();

      // Should still return false if cleanup fails
      expect(result, false);
    });

    test('should handle unexpected errors gracefully', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('Unexpected error'));

      final result = await validator.validateStorage();

      expect(result, false);
    });

    test('should clean up test data even if verification fails', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async => {});
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'mismatched_value');
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async => {});

      await validator.validateStorage();

      verify(
        () => mockStorage.delete(key: '_storage_validation_test'),
      ).called(1);
    });
  });

  group('StorageValidator - getStorageUnavailableMessage', () {
    test('should return user-friendly error message', () {
      final message = validator.getStorageUnavailableMessage();

      expect(message, isNotEmpty);
      expect(message, contains('Secure storage'));
      expect(message, contains('not available'));
    });
  });
}
