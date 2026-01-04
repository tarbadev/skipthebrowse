import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences prefs;

  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';

  AuthInterceptor(this.prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = prefs.getString(_tokenKey);
    final tokenType = prefs.getString(_tokenTypeKey);

    if (accessToken != null && tokenType != null) {
      // Capitalize token type (backend sends "bearer" but expects "Bearer")
      final capitalizedTokenType =
          tokenType[0].toUpperCase() + tokenType.substring(1);
      options.headers['Authorization'] = '$capitalizedTokenType $accessToken';
    }

    super.onRequest(options, handler);
  }
}
