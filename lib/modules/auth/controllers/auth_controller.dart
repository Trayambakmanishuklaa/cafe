import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/storage/storage_service.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  final RxString selectedRole = 'CUSTOMER'.obs;

  @override
  void onInit() {
    super.onInit();
    restoreSession();
  }

  Future<void> restoreSession() async {
    final token = await _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        final updatedUser = await _authRepository.getProfile();
        currentUser.value = updatedUser;
        await _storageService.saveUserRaw(updatedUser.toRawJson());
      } catch (e) {
        final userRaw = _storageService.getUserRaw();
        if (userRaw != null) {
          currentUser.value = UserModel.fromRawJson(userRaw);
        } else {
          await _storageService.clearAll();
        }
      }
    }
  }

  Future<void> login() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter email and password',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final dynamic res = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      final map = res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{};
      final token = map['token']?.toString() ?? '';
      final userMap = map['user'] is Map ? Map<String, dynamic>.from(map['user']) : <String, dynamic>{};
      final user = UserModel.fromJson(userMap);

      await _storageService.saveToken(token);
      await _storageService.saveUserRaw(user.toRawJson());
      currentUser.value = user;

      Get.offAllNamed(AppRoutes.NAVIGATION);
    } catch (e) {
      errorMessage.value = ErrorUtils.getCleanMessage(e);
      Get.snackbar('Login Failed', errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please fill in all required fields',
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final dynamic res = await _authRepository.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        role: selectedRole.value,
      );

      final map = res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{};
      final token = map['token']?.toString() ?? '';
      final userMap = map['user'] is Map ? Map<String, dynamic>.from(map['user']) : <String, dynamic>{};
      final user = UserModel.fromJson(userMap);

      await _storageService.saveToken(token);
      await _storageService.saveUserRaw(user.toRawJson());
      currentUser.value = user;

      Get.offAllNamed(AppRoutes.NAVIGATION);
    } catch (e) {
      errorMessage.value = ErrorUtils.getCleanMessage(e);
      Get.snackbar('Registration Failed', errorMessage.value,
          backgroundColor: Colors.red.withOpacity(0.1), colorText: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    currentUser.value = null;
    emailController.clear();
    passwordController.clear();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
