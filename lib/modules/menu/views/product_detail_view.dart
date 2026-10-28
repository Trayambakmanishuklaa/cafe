import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

class ProductDetailView extends StatefulWidget {
  final ProductModel product;

  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _quantity = 1;
  final List<String> _selectedCustomizations = [];

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Banner
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.local_cafe, size: 100, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name & Veg Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: Colors.green, size: 10),
                            SizedBox(width: 4),
                            Text('100% VEG', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price & Prep Time
                  Row(
                    children: [
                      Text(
                        '₹${widget.product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer_outlined, size: 18, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.product.prepTimeMinutes} mins prep',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.product.description,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Customizations Section
                  const Text(
                    'Customization Options',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildCustomizationOption('Extra Sugar / Less Sugar'),
                  _buildCustomizationOption('Extra Butter / Cheese'),
                  _buildCustomizationOption('Strong Kadak Brew'),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Quantity',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.primary,
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Add to Cart Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                    Text(
                      '₹${(widget.product.price * _quantity).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      cartController.addToCart(
                        widget.product,
                        quantity: _quantity,
                        customizations: _selectedCustomizations,
                      );
                      Get.back();
                    },
                    child: const Text('ADD TO CART'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationOption(String title) {
    final isChecked = _selectedCustomizations.contains(title);
    return CheckboxListTile(
      value: isChecked,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _selectedCustomizations.add(title);
          } else {
            _selectedCustomizations.remove(title);
          }
        });
      },
    );
  }
}
