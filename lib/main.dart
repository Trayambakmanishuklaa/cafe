import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'app/core/network/api_client.dart';
import 'app/core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);

  // Initialize API Client
  Get.put<ApiClient>(ApiClient(), permanent: true);

  runApp(const CafeApp());
}
