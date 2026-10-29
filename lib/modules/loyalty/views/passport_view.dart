import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/loyalty_model.dart';
import '../controllers/passport_controller.dart';

class PassportView extends StatelessWidget {
  const PassportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PassportController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cafe Passport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchPassportAndRewards(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final p = controller.passport.value;
        final points = p?.pointsBalance ?? 100;
        final tier = p?.tier ?? 'BRONZE';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIP / Passport Membership Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_cafe, color: AppColors.secondary, size: 28),
                            SizedBox(width: 8),
                            Text(
                              'CAFE PASSPORT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tier,
                            style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Available Loyalty Points', style: TextStyle(color: AppColors.secondaryLight, fontSize: 12)),
                    Text(
                      '$points PTS',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lifetime Earned: ${p?.lifetimePoints ?? 100} PTS',
                      style: const TextStyle(color: AppColors.secondaryLight, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Digital Chai & Coffee Stamp Card (10 Stamps)
              const Text('Chai & Coffee Digital Stamp Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Collect 10 stamps on visits for a FREE specialty beverage!', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final isStamped = index < ((p?.stampsCount ?? 3) % 10);
                      return Container(
                        decoration: BoxDecoration(
                          color: isStamped ? AppColors.secondaryLight : Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(color: isStamped ? AppColors.secondary : Colors.grey.shade300, width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            isStamped ? Icons.verified : Icons.local_cafe_outlined,
                            color: isStamped ? AppColors.primary : Colors.grey,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Redeemable Rewards List
              const Text('Available Rewards & Vouchers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.rewards.length,
                itemBuilder: (context, index) {
                  final reward = controller.rewards[index];
                  final canAfford = points >= reward.pointsCost;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: canAfford ? AppColors.secondaryLight : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.card_giftcard, color: canAfford ? AppColors.primary : Colors.grey),
                      ),
                      title: Text(reward.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${reward.description}\nCost: ${reward.pointsCost} Points'),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? AppColors.primary : Colors.grey,
                          minimumSize: const Size(70, 36),
                        ),
                        onPressed: canAfford ? () => controller.redeemReward(reward) : null,
                        child: const Text('CLAIM', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Transaction History Ledger
              const Text('Points Transaction Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              if (p?.transactions.isEmpty ?? true)
                const Text('No transactions yet.')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: p?.transactions.length ?? 0,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final tx = p.transactions[index];
                    final isEarn = tx.points > 0;
                    return ListTile(
                      dense: true,
                      title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt)),
                      trailing: Text(
                        '${isEarn ? "+" : ""}${tx.points} PTS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isEarn ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
