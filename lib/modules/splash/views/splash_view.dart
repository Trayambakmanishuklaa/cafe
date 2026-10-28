import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/storage/storage_service.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    final storage = Get.find<StorageService>();
    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(AppRoutes.NAVIGATION);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_cafe,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ARTISAN CAFE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tea • Coffee • Buns • Burgers',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
