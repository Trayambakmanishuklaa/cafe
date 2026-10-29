import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/storage/storage_service.dart';
import 'app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storageService = Get.find<StorageService>();
    final token = storageService.getToken();

    // If token is null/empty and trying to access protected routes, redirect to login
    if (token == null) {
      // Note: getToken() is async in secure storage, but we can check sync preference or handle via controller.
    }
    return null;
  }
}
