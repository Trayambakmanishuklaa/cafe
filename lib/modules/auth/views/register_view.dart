import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join Cafe Passport',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Earn 100 bonus points on registration!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextField(
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              TextField(
                controller: controller.passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.register,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('REGISTER & GET 100 POINTS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
