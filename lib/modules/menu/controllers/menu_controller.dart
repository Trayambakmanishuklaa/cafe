import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/menu_repository.dart';

class CafeMenuController extends GetxController {
  final MenuRepository _menuRepository = Get.put(MenuRepository(Get.find()));

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  final RxString selectedCategorySlug = ''.obs;
  final searchController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategoriesAndProducts();
  }

  Future<void> loadCategoriesAndProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final cats = await _menuRepository.getCategories();
      categories.assignAll(cats);

      final prods = await _menuRepository.getProducts();
      products.assignAll(prods);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> filterByCategory(String slug) async {
    selectedCategorySlug.value = slug;
    try {
      isLoading.value = true;
      final prods = await _menuRepository.getProducts(
        categorySlug: slug.isEmpty ? null : slug,
        search: searchController.text.trim(),
      );
      products.assignAll(prods);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      isLoading.value = true;
      final prods = await _menuRepository.getProducts(
        categorySlug: selectedCategorySlug.value.isEmpty ? null : selectedCategorySlug.value,
        search: query.trim(),
      );
      products.assignAll(prods);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
