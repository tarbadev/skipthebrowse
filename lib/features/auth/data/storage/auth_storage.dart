import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
}

class SecureAuthStorage implements AuthStorage {
  final FlutterSecureStorage _storage;
  SecureAuthStorage(this._storage);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}

class InsecureAuthStorage implements AuthStorage {
  final SharedPreferences _prefs;
  InsecureAuthStorage(this._prefs);

  @override
  Future<void> write({required String key, required String value}) =>
      _prefs.setString(key, value);

  @override
  Future<String?> read({required String key}) async => _prefs.getString(key);

  @override
  Future<void> delete({required String key}) => _prefs.remove(key);
}
