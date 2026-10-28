import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/cart_controller.dart';
import '../../checkout/views/checkout_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => cartController.clearCart(),
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explore our fresh Tea, Coffee, Buns & Burgers!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('EXPLORE MENU'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Type Selector
                    const Text('Order Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Dine In')),
                              selected: cartController.selectedOrderType.value == 'DINE_IN',
                              onSelected: (_) => cartController.selectedOrderType.value = 'DINE_IN',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: cartController.selectedOrderType.value == 'DINE_IN' ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Takeaway')),
                              selected: cartController.selectedOrderType.value == 'TAKEAWAY',
                              onSelected: (_) => cartController.selectedOrderType.value = 'TAKEAWAY',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: cartController.selectedOrderType.value == 'TAKEAWAY' ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Items List
                    const Text('Selected Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartController.cartItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = cartController.cartItems[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.fastfood, color: AppColors.primary, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        '₹${item.product.price.toStringAsFixed(0)} each',
                                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () => cartController.updateQuantity(item.product.id, -1),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => cartController.updateQuantity(item.product.id, 1),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Coupon Input
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: cartController.couponController,
                                decoration: const InputDecoration(
                                  hintText: 'Try Coupon "WELCOME10"',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 45)),
                              onPressed: () => cartController.applyCoupon(),
                              child: const Text('APPLY'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bill Summary Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bill Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Divider(height: 20),
                            _buildBillRow('Item Subtotal', '₹${cartController.subtotal.toStringAsFixed(2)}'),
                            if (cartController.couponDiscount.value > 0)
                              _buildBillRow(
                                'Coupon Discount',
                                '- ₹${cartController.couponDiscount.value.toStringAsFixed(2)}',
                                textColor: Colors.green,
                              ),
                            _buildBillRow('GST & Taxes (5%)', '₹${cartController.tax.toStringAsFixed(2)}'),
                            const Divider(height: 20),
                            _buildBillRow(
                              'To Pay',
                              '₹${cartController.grandTotal.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Checkout Button
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const CheckoutView()),
                child: Text('PROCEED TO CHECKOUT (₹${cartController.grandTotal.toStringAsFixed(2)})'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBillRow(String label, String value, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
