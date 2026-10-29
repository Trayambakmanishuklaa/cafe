import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../data/models/loyalty_model.dart';
import '../../../data/repositories/loyalty_repository.dart';

class PassportController extends GetxController {
  final LoyaltyRepository _repository = Get.put(LoyaltyRepository(Get.find()));

  final Rxn<PassportDataModel> passport = Rxn<PassportDataModel>();
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPassportAndRewards();
  }

  Future<void> fetchPassportAndRewards() async {
    try {
      isLoading.value = true;
      final p = await _repository.getPassport();
      passport.value = p;

      final rList = await _repository.getRewards();
      rewards.assignAll(rList);
    } catch (e) {
      Get.snackbar('Passport Error', ErrorUtils.getCleanMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> redeemReward(RewardModel reward) async {
    if ((passport.value?.pointsBalance ?? 0) < reward.pointsCost) {
      Get.snackbar('Insufficient Points', 'You need ${reward.pointsCost} points to redeem this reward.');
      return;
    }

    try {
      await _repository.redeemReward(reward.id);
      Get.snackbar('🎉 Reward Redeemed!', 'Check your email/voucher list for your discount code!',
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      fetchPassportAndRewards();
    } catch (e) {
      Get.snackbar('Redeem Failed', ErrorUtils.getCleanMessage(e));
    }
  }
}
