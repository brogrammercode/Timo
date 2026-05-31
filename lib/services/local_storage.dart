import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPrefs;

  LocalStorage({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPrefs,
  })  : _secureStorage = secureStorage,
        _sharedPrefs = sharedPrefs;

  static const String _activeSessionIdKey = 'active_session_id';

  // Secure Storage for sensitive values (if any)
  Future<void> saveSecureValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecureValue(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecureValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Shared Preferences for non-sensitive values
  Future<void> saveActiveSessionId(String sessionId) async {
    await _sharedPrefs.setString(_activeSessionIdKey, sessionId);
  }

  String? getActiveSessionId() {
    return _sharedPrefs.getString(_activeSessionIdKey);
  }

  Future<void> clearActiveSessionId() async {
    await _sharedPrefs.remove(_activeSessionIdKey);
  }
}

