import '../../app/core/network/api_client.dart';
import '../models/loyalty_model.dart';

class LoyaltyRepository {
  final ApiClient _apiClient;

  LoyaltyRepository(this._apiClient);

  Future<PassportDataModel> getPassport() async {
    final response = await _apiClient.get('/loyalty/me');
    return PassportDataModel.fromJson(response.data['data']);
  }

  Future<List<RewardModel>> getRewards() async {
    final response = await _apiClient.get('/loyalty/rewards');
    final List<dynamic> list = response.data['data'];
    return list.map((json) => RewardModel.fromJson(json)).toList();
  }

  Future<void> redeemReward(String rewardId) async {
    await _apiClient.post('/loyalty/rewards/$rewardId/redeem');
  }
}
