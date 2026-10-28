import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/order_repository.dart';

class CartController extends GetxController {
  final OrderRepository _orderRepository = Get.put(OrderRepository(Get.find()));

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxString selectedOrderType = 'DINE_IN'.obs;
  final couponController = TextEditingController();
  final RxString appliedCoupon = ''.obs;
  final RxDouble couponDiscount = 0.0.obs;

  final RxBool isPlacingOrder = false.obs;

  int get totalItemCount => cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.itemTotal);

  double get tax => MathUtils.roundToTwoDecimals((subtotal - couponDiscount.value) * 0.05);

  double get grandTotal => (subtotal - couponDiscount.value + tax).clamp(0.0, double.infinity);

  void addToCart(ProductModel product, {int quantity = 1, List<String>? customizations}) {
    final existingIndex = cartItems.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItemModel(
        product: product,
        quantity: quantity,
        customizations: customizations,
      ));
    }
    Get.snackbar(
      'Added to Cart',
      '${product.name} added to your cart!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.brown.withOpacity(0.9),
      colorText: Colors.white,
    );
  }

  void updateQuantity(String productId, int delta) {
    final index = cartItems.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      cartItems[index].quantity += delta;
      if (cartItems[index].quantity <= 0) {
        cartItems.removeAt(index);
      } else {
        cartItems.refresh();
      }
    }
  }

  void clearCart() {
    cartItems.clear();
    appliedCoupon.value = '';
    couponDiscount.value = 0.0;
    couponController.clear();
  }

  void applyCoupon() {
    final code = couponController.text.trim().toUpperCase();
    if (code == 'WELCOME10') {
      couponDiscount.value = subtotal * 0.10;
      appliedCoupon.value = code;
      Get.snackbar('Coupon Applied', 'You saved 10% on your order!',
          backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
    } else {
      Get.snackbar('Invalid Coupon', 'Coupon code is invalid or expired',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    }
  }

  Future<OrderModel?> placeOrder({String? tableId, String? bookingId}) async {
    if (cartItems.isEmpty) {
      Get.snackbar('Empty Cart', 'Please add items to your cart first');
      return null;
    }

    try {
      isPlacingOrder.value = true;

      final itemsPayload = cartItems.map((item) => item.toServerJson()).toList();

      final order = await _orderRepository.createOrder(
        orderType: selectedOrderType.value,
        tableId: tableId,
        bookingId: bookingId,
        couponCode: appliedCoupon.value.isNotEmpty ? appliedCoupon.value : null,
        items: itemsPayload,
      );

      clearCart();
      return order;
    } catch (e) {
      Get.snackbar('Order Failed', e.toString(),
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return null;
    } finally {
      isPlacingOrder.value = false;
    }
  }
}

class MathUtils {
  static double roundToTwoDecimals(double val) {
    return (val * 100).roundToDouble() / 100;
  }
}
