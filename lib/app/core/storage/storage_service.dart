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
    await _secureStorage.write(key: ApiConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: ApiConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: ApiConstants.tokenKey);
  }

  Future<void> saveUserRaw(String jsonUser) async {
    await _prefs.setString(ApiConstants.userKey, jsonUser);
  }

  String? getUserRaw() {
    return _prefs.getString(ApiConstants.userKey);
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}
