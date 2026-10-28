import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/menu_controller.dart';
import 'product_detail_view.dart';
import '../../cart/views/cart_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = Get.put(CafeMenuController());
    final cartController = Get.put(CartController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Artisan Menu'),
        actions: [
          Obx(
            () => badges.Badge(
              position: badges.BadgePosition.topEnd(top: 2, end: 4),
              showBadge: cartController.totalItemCount > 0,
              badgeContent: Text(
                '${cartController.totalItemCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              badgeStyle: const badges.BadgeStyle(badgeColor: AppColors.primary),
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                onPressed: () => Get.to(() => const CartView()),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: menuController.searchController,
              onChanged: (val) => menuController.searchProducts(val),
              decoration: InputDecoration(
                hintText: 'Search Tea, Coffee, Buns & Burgers...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    menuController.searchController.clear();
                    menuController.searchProducts('');
                  },
                ),
              ),
            ),
          ),

          // Category Chips (All, Tea, Coffee, Bun & Bakery, Burger)
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildCategoryFilterChip(
                    label: 'All Items',
                    icon: Icons.restaurant,
                    isSelected: menuController.selectedCategorySlug.value.isEmpty,
                    onTap: () => menuController.filterByCategory(''),
                  ),
                  ...menuController.categories.map((cat) {
                    final isSelected = menuController.selectedCategorySlug.value == cat.slug;
                    return _buildCategoryFilterChip(
                      label: cat.name,
                      icon: _getCategoryIcon(cat.slug),
                      isSelected: isSelected,
                      onTap: () => menuController.filterByCategory(cat.slug),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Product Grid View
          Expanded(
            child: Obx(() {
              if (menuController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (menuController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(menuController.errorMessage.value),
                      ElevatedButton(
                        onPressed: () => menuController.loadCategoriesAndProducts(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (menuController.products.isEmpty) {
                return const Center(
                  child: Text('No products found matching your search.'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: menuController.products.length,
                itemBuilder: (context, index) {
                  final product = menuController.products[index];
                  return _buildProductCard(context, product, cartController);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  static IconData _getCategoryIcon(String slug) {
    switch (slug) {
      case 'tea':
        return Icons.emoji_food_beverage;
      case 'coffee':
        return Icons.coffee;
      case 'bun-bakery':
        return Icons.bakery_dining;
      case 'burger':
        return Icons.lunch_dining;
      default:
        return Icons.fastfood;
    }
  }

  Widget _buildCategoryFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.primary),
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, CartController cartController) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.to(() => ProductDetailView(product: product)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Header with Veg Indicator
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: AppColors.secondaryLight,
                  child: Center(
                    child: Icon(
                      _getCategoryIconByProduct(product),
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Icon(Icons.circle, color: Colors.green, size: 10),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textLight, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      InkWell(
                        onTap: () => cartController.addToCart(product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _getCategoryIconByProduct(ProductModel product) {
    final nameLower = product.name.toLowerCase();
    if (nameLower.contains('tea') || nameLower.contains('chai')) return Icons.emoji_food_beverage;
    if (nameLower.contains('coffee') || nameLower.contains('espresso') || nameLower.contains('latte') || nameLower.contains('mocha')) return Icons.coffee;
    if (nameLower.contains('bun')) return Icons.bakery_dining;
    if (nameLower.contains('burger')) return Icons.lunch_dining;
    return Icons.local_cafe;
  }
}
