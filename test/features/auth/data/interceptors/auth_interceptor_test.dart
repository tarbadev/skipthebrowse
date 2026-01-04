import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skipthebrowse/features/auth/data/interceptors/auth_interceptor.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockSharedPreferences mockPrefs;
  late AuthInterceptor interceptor;
  late MockRequestInterceptorHandler mockHandler;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    interceptor = AuthInterceptor(mockPrefs);
    mockHandler = MockRequestInterceptorHandler();
  });

  group('AuthInterceptor - onRequest', () {
    test('should add Authorization header when token exists', () {
      when(() => mockPrefs.getString('auth_token')).thenReturn('test-token');
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');

      interceptor.onRequest(requestOptions, mockHandler);

      expect(requestOptions.headers['Authorization'], 'Bearer test-token');
      verify(() => mockHandler.next(requestOptions)).called(1);
    });

    test('should not add Authorization header when no token exists', () {
      when(() => mockPrefs.getString('auth_token')).thenReturn(null);
      when(() => mockPrefs.getString('token_type')).thenReturn(null);
      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');

      interceptor.onRequest(requestOptions, mockHandler);

      expect(requestOptions.headers.containsKey('Authorization'), false);
      verify(() => mockHandler.next(requestOptions)).called(1);
    });

    test('should not add Authorization header when token is null', () {
      when(() => mockPrefs.getString('auth_token')).thenReturn('test-token');
      when(() => mockPrefs.getString('token_type')).thenReturn(null);
      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');

      interceptor.onRequest(requestOptions, mockHandler);

      expect(requestOptions.headers.containsKey('Authorization'), false);
      verify(() => mockHandler.next(requestOptions)).called(1);
    });

    test('should not add Authorization header when token type is null', () {
      when(() => mockPrefs.getString('auth_token')).thenReturn(null);
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(path: '/test');

      interceptor.onRequest(requestOptions, mockHandler);

      expect(requestOptions.headers.containsKey('Authorization'), false);
      verify(() => mockHandler.next(requestOptions)).called(1);
    });

    test('should preserve existing headers when adding Authorization', () {
      when(() => mockPrefs.getString('auth_token')).thenReturn('test-token');
      when(() => mockPrefs.getString('token_type')).thenReturn('bearer');
      when(() => mockHandler.next(any())).thenReturn(null);

      final requestOptions = RequestOptions(
        path: '/test',
        headers: {
          'Content-Type': 'application/json',
          'Custom-Header': 'custom-value',
        },
      );

      interceptor.onRequest(requestOptions, mockHandler);

      expect(requestOptions.headers['Authorization'], 'Bearer test-token');
      expect(requestOptions.headers['Content-Type'], 'application/json');
      expect(requestOptions.headers['Custom-Header'], 'custom-value');
      verify(() => mockHandler.next(requestOptions)).called(1);
    });
  });
}
