import '../../app/core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Map<String, dynamic> _extractDataMap(dynamic responseData) {
    if (responseData is Map) {
      final data = responseData['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return Map<String, dynamic>.from(responseData);
    }
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _extractDataMap(response.data);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'CUSTOMER',
  }) async {
    final response = await _apiClient.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'role': role,
    });
    return _extractDataMap(response.data);
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get('/auth/me');
    final map = _extractDataMap(response.data);
    final userJson = map['user'] ?? map;
    return UserModel.fromJson(userJson);
  }
}
