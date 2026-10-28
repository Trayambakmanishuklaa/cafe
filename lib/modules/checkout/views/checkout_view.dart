import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/order_model.dart';
import '../../cart/controllers/cart_controller.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _selectedPaymentMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment & Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Brief
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Total Items: ${cartController.totalItemCount}'),
                    Text('Order Type: ${cartController.selectedOrderType.value}'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount Payable', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '₹${cartController.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Payment Method
            const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _buildPaymentOption('UPI', 'Google Pay, PhonePe, Paytm', Icons.qr_code_2),
            _buildPaymentOption('CARD', 'Credit / Debit Card', Icons.credit_card),
            _buildPaymentOption('CASH_AT_COUNTER', 'Pay Cash at Counter', Icons.payments),
            const SizedBox(height: 36),

            // Confirm Order Button
            Obx(
              () => ElevatedButton(
                onPressed: cartController.isPlacingOrder.value
                    ? null
                    : () async {
                        final order = await cartController.placeOrder();
                        if (order != null) {
                          _showSuccessDialog(order);
                        }
                      },
                child: cartController.isPlacingOrder.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('CONFIRM & PLACE ORDER'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return Card(
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        activeColor: AppColors.primary,
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedPaymentMethod = val;
            });
          }
        },
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        secondary: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  void _showSuccessDialog(OrderModel order) {
    Get.defaultDialog(
      title: '🎉 Order Placed!',
      barrierDismissible: false,
      content: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 12),
          Text(
            'Order #${order.orderNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Amount Paid: ₹${order.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your order has been sent to our kitchen. You will receive real-time updates!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.offAllNamed(AppRoutes.NAVIGATION);
        },
        child: const Text('BACK TO HOME'),
      ),
    );
  }
}
