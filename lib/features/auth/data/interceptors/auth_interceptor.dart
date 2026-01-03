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
      options.headers['Authorization'] = '$tokenType $accessToken';
    }

    super.onRequest(options, handler);
  }
}
