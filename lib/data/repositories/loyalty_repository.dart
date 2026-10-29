import '../../app/core/network/api_client.dart';
import '../models/loyalty_model.dart';

class LoyaltyRepository {
  final ApiClient _apiClient;

  LoyaltyRepository(this._apiClient);

  Map<String, dynamic> _extractMap(dynamic responseData) {
    if (responseData is Map) {
      if (responseData['data'] is Map) {
        return Map<String, dynamic>.from(responseData['data']);
      }
      return Map<String, dynamic>.from(responseData);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map && responseData['data'] is List) {
      return responseData['data'] as List<dynamic>;
    }
    if (responseData is List) {
      return responseData;
    }
    return <dynamic>[];
  }

  Future<PassportDataModel> getPassport() async {
    final response = await _apiClient.get('/loyalty/me');
    return PassportDataModel.fromJson(_extractMap(response.data));
  }

  Future<List<RewardModel>> getRewards() async {
    final response = await _apiClient.get('/loyalty/rewards');
    final list = _extractList(response.data);
    return list.map((json) => RewardModel.fromJson(json)).toList();
  }

  Future<void> redeemReward(String rewardId) async {
    await _apiClient.post('/loyalty/rewards/$rewardId/redeem');
  }
}
