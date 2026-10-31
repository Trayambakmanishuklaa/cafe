import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../loyalty/controllers/passport_controller.dart';
import '../../menu/controllers/menu_controller.dart';
import '../../menu/views/menu_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final passportController = Get.put(PassportController());
    final menuController = Get.put(CafeMenuController());

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
        final passport = passportController.passport.value;
        final progressText = passport?.progressText ?? '0/4 Tea orders completed';
        final progressVal = ((passport?.teaOrdersProgress ?? 0) / 4.0).clamp(0.0, 1.0);

        return SingleChildScrollView(
          padding: AppResponsive.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Greeting Header
              Text(
                'Hello, ${user?.name ?? "Coffee Lover"}! 👋',
                style: TextStyle(
                  fontSize: AppResponsive.getResponsiveFontSize(context, 22),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Brewing fresh Tea, Coffee, Buns & Burgers for you',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // 4 Main Categories Prominently Displayed
              const Text(
                'Explore Menu Categories',
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
                crossAxisCount: AppResponsive.getGridCrossAxisCount(context, phone: 2, tablet: 4, landscape: 4),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _buildCategoryCard('Tea Corner', Icons.emoji_food_beverage, 'Masala, Ginger & Kulhad', () {
                    menuController.filterByCategory('tea');
                    Get.to(() => const MenuView());
                  }),
                  _buildCategoryCard('Coffee Corner', Icons.coffee, 'Espresso, Latte & Cold Coffee', () {
                    menuController.filterByCategory('coffee');
                    Get.to(() => const MenuView());
                  }),
                  _buildCategoryCard('Bun & Bakery', Icons.bakery_dining, 'Bun Maska & Butter Buns', () {
                    menuController.filterByCategory('bun-bakery');
                    Get.to(() => const MenuView());
                  }),
                  _buildCategoryCard('Burger Station', Icons.lunch_dining, 'Crispy Veg & Cheese Burgers', () {
                    menuController.filterByCategory('burger');
                    Get.to(() => const MenuView());
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // Loyalty Points & Free Tea Reward Card Prominently Displayed
              const Text(
                '☕ Loyalty Points & Free Tea Progress',
                style: TextStyle(
                  fontSize: 18,
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
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars, color: AppColors.secondary, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              '${passport?.pointsBalance ?? user?.loyaltyPoints ?? 100} PTS',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            passport?.tier ?? user?.membershipTier ?? 'BRONZE',
                            style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tea Order Progress:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          progressText,
                          style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Every 4 completed Tea orders earn 1 Free Tea reward for your next order!',
                      style: TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recommendations / Special Combos Carousel
              const Text(
                'Chef Recommended Combos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fastfood, color: AppColors.primary, size: 36),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kulhad Chai + Bun Maska', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            SizedBox(height: 4),
                            Text('Classic Afternoon Combo • Save ₹15!', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                            SizedBox(height: 6),
                            Text('₹85', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildCategoryCard(String title, IconData icon, String subtitle, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textLight, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
