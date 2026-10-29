import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../menu/controllers/menu_controller.dart';

class StaffProductManagementView extends StatefulWidget {
  const StaffProductManagementView({super.key});

  @override
  State<StaffProductManagementView> createState() => _StaffProductManagementViewState();
}

class _StaffProductManagementViewState extends State<StaffProductManagementView> {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final CafeMenuController _menuController = Get.put(CafeMenuController());
  final ImagePicker _picker = ImagePicker();

  List<ProductModel> _products = [];
  bool _isLoading = true;

  // Form Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedCategorySlug = 'tea';
  bool _isAvailable = true;
  bool _isVeg = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final res = await _apiClient.get('/products/staff/all');
      final List<dynamic> list = res.data['data'] ?? [];
      setState(() {
        _products = list.map((json) => ProductModel.fromJson(json)).toList();
      });
    } catch (e) {
      Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery(StateSetter setModalState) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64String';

        setModalState(() {
          _imageUrlController.text = dataUrl;
        });

        Get.snackbar('Photo Selected', 'Image selected from gallery successfully!',
            backgroundColor: const Color(0x1A4CAF50), colorText: Colors.green);
      }
    } catch (e) {
      Get.snackbar('Image Picker Error', e.toString());
    }
  }

  Future<void> _toggleAvailability(ProductModel product, bool val) async {
    try {
      await _apiClient.patch('/products/${product.id}/availability', data: {
        'isAvailable': val,
      });
      _fetchProducts();
      _menuController.loadCategoriesAndProducts(); // sync customer menu
    } catch (e) {
      Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _saveProduct({ProductModel? existingProduct}) async {
    if (_nameController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please fill in product name, description and price');
      return;
    }

    final priceVal = double.tryParse(_priceController.text.trim());
    if (priceVal == null || priceVal <= 0) {
      Get.snackbar('Validation Error', 'Price must be greater than 0');
      return;
    }

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'categorySlug': _selectedCategorySlug,
        'price': priceVal,
        'imageUrl': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'isAvailable': _isAvailable,
        'isVeg': _isVeg,
      };

      if (existingProduct == null) {
        // Create Product
        await _apiClient.post('/products', data: payload);
        Get.snackbar('Product Added', 'New product added to customer menu!',
            backgroundColor: const Color(0x1A4CAF50), colorText: Colors.green);
      } else {
        // Edit Product
        await _apiClient.patch('/products/${existingProduct.id}', data: payload);
        Get.snackbar('Product Updated', 'Product updated successfully!',
            backgroundColor: const Color(0x1A4CAF50), colorText: Colors.green);
      }

      Get.back(); // close modal
      _clearForm();
      _fetchProducts();
      _menuController.loadCategoriesAndProducts(); // Sync Customer Menu
    } catch (e) {
      Get.snackbar('Save Error', ErrorUtils.getCleanMessage(e));
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _selectedCategorySlug = 'tea';
    _isAvailable = true;
    _isVeg = true;
  }

  void _openProductFormModal({ProductModel? product}) {
    if (product != null) {
      _nameController.text = product.name;
      _descController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(0);
      _imageUrlController.text = product.imageUrl ?? '';
      _isAvailable = product.isAvailable;
      _isVeg = product.isVeg;
      _selectedCategorySlug = _getCategorySlugFromId(product.categoryId);
    } else {
      _clearForm();
    }

    Get.defaultDialog(
      title: product == null ? '➕ Add New Product' : '✏️ Edit Product',
      content: StatefulBuilder(
        builder: (context, setModalState) {
          final hasImage = _imageUrlController.text.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Image Picker Preview Box
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: hasImage
                      ? _buildProductImagePreview(_imageUrlController.text)
                      : const Center(
                          child: Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
                        ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(40),
                  ),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('SELECT FROM MOBILE GALLERY'),
                  onPressed: () => _pickImageFromGallery(setModalState),
                ),
                const SizedBox(height: 12),

                // Name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 10),

                // Description
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategorySlug,
                  decoration: const InputDecoration(labelText: 'Category (Required)'),
                  items: const [
                    DropdownMenuItem(value: 'tea', child: Text('Tea Corner')),
                    DropdownMenuItem(value: 'coffee', child: Text('Coffee Corner')),
                    DropdownMenuItem(value: 'bun-bakery', child: Text('Bun & Bakery')),
                    DropdownMenuItem(value: 'burger', child: Text('Burger Station')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => _selectedCategorySlug = val);
                  },
                ),
                const SizedBox(height: 10),

                // Price
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (₹)'),
                ),
                const SizedBox(height: 10),

                // Availability Toggle
                SwitchListTile(
                  title: const Text('Available in Customer Menu'),
                  value: _isAvailable,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setModalState(() => _isAvailable = val),
                ),
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        onPressed: () => _saveProduct(existingProduct: product),
        child: Text(product == null ? 'SAVE PRODUCT' : 'UPDATE PRODUCT'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('CANCEL'),
      ),
    );
  }

  Widget _buildProductImagePreview(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Bytes = base64Decode(imageUrl.split(',').last);
        return Image.memory(base64Bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 40, color: AppColors.primary),
    );
  }

  String _getCategorySlugFromId(String categoryId) {
    if (categoryId.contains('tea')) return 'tea';
    if (categoryId.contains('coffee')) return 'coffee';
    if (categoryId.contains('bun')) return 'bun-bakery';
    if (categoryId.contains('burger')) return 'burger';
    return 'tea';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Product Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductFormModal(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('ADD PRODUCT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _products.isEmpty
              ? const Center(child: Text('No staff products found. Tap ADD PRODUCT to create one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                                  ? _buildProductImagePreview(product.imageUrl!)
                                  : const Icon(Icons.fastfood, color: AppColors.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text('₹${product.price.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                  Text(
                                    product.isAvailable ? 'Available' : 'Out of Stock',
                                    style: TextStyle(color: product.isAvailable ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: product.isAvailable,
                              activeThumbColor: AppColors.primary,
                              onChanged: (val) => _toggleAvailability(product, val),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.primary),
                              onPressed: () => _openProductFormModal(product: product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
