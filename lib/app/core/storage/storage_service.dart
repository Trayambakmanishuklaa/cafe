import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class StorageService extends GetxService {
  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _secureStorage = const FlutterSecureStorage();
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: ApiConstants.tokenKey, value: token);
    } catch (_) {}
    await _prefs.setString(ApiConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    String? token;
    try {
      token = await _secureStorage.read(key: ApiConstants.tokenKey);
    } catch (_) {
      token = null;
    }
    // Fallback to SharedPreferences if secure storage fails or is null after app process kill / background removal
    if (token == null || token.isEmpty) {
      token = _prefs.getString(ApiConstants.tokenKey);
    }
    return token;
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: ApiConstants.tokenKey);
    } catch (_) {}
    await _prefs.remove(ApiConstants.tokenKey);
  }

  Future<void> saveUserRaw(String jsonUser) async {
    await _prefs.setString(ApiConstants.userKey, jsonUser);
  }

  String? getUserRaw() {
    return _prefs.getString(ApiConstants.userKey);
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    await _prefs.clear();
  }
}
