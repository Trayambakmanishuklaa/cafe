import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/repositories/video_review_repository.dart';

class SocialMediaSettingsView extends StatefulWidget {
  final bool isModalOnboarding;
  const SocialMediaSettingsView({super.key, this.isModalOnboarding = false});

  @override
  State<SocialMediaSettingsView> createState() => _SocialMediaSettingsViewState();
}

class _SocialMediaSettingsViewState extends State<SocialMediaSettingsView> {
  final VideoReviewRepository _repo = VideoReviewRepository(Get.find<ApiClient>());
  List<dynamic> _accounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getSocialAccounts();
      setState(() => _accounts = list);
    } catch (e) {
      Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _connectAccount(String platform, String displayName) async {
    try {
      await _repo.connectSocialAccount(platform, displayName, 'acc_${platform.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}');
      Get.snackbar('Connected!', 'Successfully connected official $platform account',
          backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
      _fetchAccounts();
    } catch (e) {
      Get.snackbar('Connection Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect Cafe to Social Media'),
        automaticallyImplyLeading: !widget.isModalOnboarding,
      ),
      body: _isLoading
          ? const AppLoader()
          : SingleChildScrollView(
              padding: AppResponsive.getScreenPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isModalOnboarding) ...[
                    const Text(
                      '🌟 Connect Your Cafe to Social Media!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create or connect your cafe official Instagram and YouTube accounts to share customer video reviews directly through this app.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // YouTube Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.video_collection, color: Colors.red, size: 32),
                              const SizedBox(width: 12),
                              const Text('YouTube Shorts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Connect official YouTube channel to upload approved video reviews directly.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            icon: const Icon(Icons.link),
                            label: const Text('Connect YouTube Account'),
                            onPressed: () => _connectAccount('YOUTUBE', 'Shubh\'s Cafe Official'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instagram Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.camera_alt, color: Colors.purple, size: 32),
                              const SizedBox(width: 12),
                              const Text('Instagram Reels', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Connect eligible Instagram Professional account for automated Reels publishing.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                            icon: const Icon(Icons.link),
                            label: const Text('Connect Instagram Account'),
                            onPressed: () => _connectAccount('INSTAGRAM', '@shubhs_cafe'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (widget.isModalOnboarding) ...[
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Skip for Now'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
