import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../staff/views/staff_order_queue_view.dart';
import '../../owner/views/owner_dashboard_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Artisan Cafe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Switcher Bar for Staff & Owner
              if (user?.isStaff == true || user?.isOwner == true) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Role: ${user?.role}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const Spacer(),
                      if (user?.isStaff == true || user?.isOwner == true)
                        TextButton.icon(
                          onPressed: () => Get.to(() => const StaffOrderQueueView()),
                          icon: const Icon(Icons.kitchen, size: 18),
                          label: const Text('Staff Queue'),
                        ),
                      if (user?.isOwner == true)
                        TextButton.icon(
                          onPressed: () => Get.to(() => const OwnerDashboardView()),
                          icon: const Icon(Icons.dashboard, size: 18),
                          label: const Text('Owner KPIs'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Greeting & Loyalty Header Card
              Text(
                'Hello, ${user?.name ?? "Coffee Lover"}! 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.secondary, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Membership: ${user?.membershipTier ?? "BRONZE"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Passport Balance: ${user?.loyaltyPoints ?? 100} Points',
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories Header
              const Text(
                'Main Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildCategoryCard('Tea Corner', Icons.emoji_food_beverage, 'Masala, Ginger & Kulhad'),
                  _buildCategoryCard('Coffee Corner', Icons.coffee, 'Espresso, Latte & Cold Coffee'),
                  _buildCategoryCard('Bun & Bakery', Icons.bakery_dining, 'Bun Maska & Butter Buns'),
                  _buildCategoryCard('Burger Station', Icons.lunch_dining, 'Crispy Veg & Cheese Burgers'),
                ],
              ),
              const SizedBox(height: 24),

              // Smart Salesperson Combo Recommendation Card
              const Text(
                '💡 Smart Salesperson Combos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant, color: AppColors.primary, size: 36),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Masala Chai + Bun Maska',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Classic Afternoon Combo • Save ₹15!',
                              style: TextStyle(color: AppColors.textLight, fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '₹70 (Was ₹85)',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, String subtitle) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textLight, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
