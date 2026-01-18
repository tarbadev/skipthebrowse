import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late AuthInterceptor interceptor;
  late MockRequestInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    interceptor = AuthInterceptor(mockStorage);
    mockHandler = MockRequestInterceptorHandler();
  });

  group('AuthInterceptor - onRequest', () {
    test('should add Authorization header when token exists', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'test-token');
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => 'bearer');

      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');

      interceptor.onRequest(requestOptions, mockHandler);

      // Wait for the async work inside onRequest to complete
      await untilCalled(() => mockHandler.next(any()));

      expect(requestOptions.headers['Authorization'], 'Bearer test-token');
      verify(() => mockHandler.next(requestOptions)).called(1);
    });

    test('should not add Authorization header when no token exists', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => null);
      when(
        () => mockStorage.read(key: 'token_type'),
      ).thenAnswer((_) async => null);
      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');

      interceptor.onRequest(requestOptions, mockHandler);

      await untilCalled(() => mockHandler.next(any()));

      expect(requestOptions.headers.containsKey('Authorization'), false);
      verify(() => mockHandler.next(requestOptions)).called(1);
    });

    test(
      'should preserve existing headers when adding Authorization',
      () async {
        when(
          () => mockStorage.read(key: 'auth_token'),
        ).thenAnswer((_) async => 'test-token');
        when(
          () => mockStorage.read(key: 'token_type'),
        ).thenAnswer((_) async => 'bearer');
        when(() => mockHandler.next(any())).thenReturn(null);

        final requestOptions = RequestOptions(
          path: '/test',
          headers: {
            'Content-Type': 'application/json',
            'Custom-Header': 'custom-value',
          },
        );

        interceptor.onRequest(requestOptions, mockHandler);

        await untilCalled(() => mockHandler.next(any()));

        expect(requestOptions.headers['Authorization'], 'Bearer test-token');
        expect(requestOptions.headers['Content-Type'], 'application/json');
        expect(requestOptions.headers['Custom-Header'], 'custom-value');
        verify(() => mockHandler.next(requestOptions)).called(1);
      },
    );
  });
}
