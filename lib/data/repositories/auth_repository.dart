import '../../app/core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['data'];
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
    return response.data['data'];
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response.data['data']['user']);
  }
}
