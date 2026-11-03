import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/video_review_model.dart';
import '../../../data/repositories/video_review_repository.dart';
import 'admin_video_editor_screen.dart';
import 'social_media_settings_view.dart';

class AdminVideoReviewScreen extends StatefulWidget {
  const AdminVideoReviewScreen({super.key});

  @override
  State<AdminVideoReviewScreen> createState() => _AdminVideoReviewScreenState();
}

class _AdminVideoReviewScreenState extends State<AdminVideoReviewScreen> with SingleTickerProviderStateMixin {
  final VideoReviewRepository _repo = VideoReviewRepository(Get.find<ApiClient>());
  late TabController _tabController;

  List<VideoReviewModel> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchReviews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getReviews();
      setState(() => _reviews = list);
    } catch (e) {
      Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _repo.approveReview(id);
      Get.snackbar('Approved', 'Video review approved successfully', backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
      _fetchReviews();
    } catch (e) {
      Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _reject(String id) async {
    String reason = 'Does not meet cafe quality guidelines';
    Get.defaultDialog(
      title: 'Reject Video Review',
      content: TextField(
        onChanged: (val) => reason = val,
        decoration: const InputDecoration(labelText: 'Rejection Reason'),
      ),
      textConfirm: 'Reject',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        try {
          await _repo.rejectReview(id, reason);
          Get.snackbar('Rejected', 'Video review rejected');
          _fetchReviews();
        } catch (e) {
          Get.snackbar('Error', ErrorUtils.getCleanMessage(e));
        }
      },
    );
  }

  Future<void> _publishYouTube(String id) async {
    try {
      await _repo.publishToYouTube(id);
      Get.snackbar('Published!', 'Video published to YouTube Shorts successfully', backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
      _fetchReviews();
    } catch (e) {
      Get.snackbar('Publish Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _publishInstagram(String id) async {
    try {
      await _repo.publishToInstagram(id);
      Get.snackbar('Published!', 'Video published to Instagram Reels successfully', backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
      _fetchReviews();
    } catch (e) {
      Get.snackbar('Publish Failed', ErrorUtils.getCleanMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _reviews.where((r) => r.status == 'PENDING_ADMIN_APPROVAL').toList();
    final approved = _reviews.where((r) => r.status == 'APPROVED' || r.status == 'READY_TO_PUBLISH').toList();
    final published = _reviews.where((r) => r.status == 'PUBLISHED').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin - Customer Video Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Social Media Accounts',
            onPressed: () => Get.to(() => const SocialMediaSettingsView()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchReviews,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: AppColors.secondary,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved (${approved.length})'),
            Tab(text: 'Published (${published.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const AppLoader()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildReviewList(pending, isPending: true),
                _buildReviewList(approved, isApproved: true),
                _buildReviewList(published, isPublished: true),
              ],
            ),
    );
  }

  Widget _buildReviewList(List<VideoReviewModel> list, {bool isPending = false, bool isApproved = false, bool isPublished = false}) {
    if (list.isEmpty) {
      return const Center(child: Text('No video reviews in this section.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final review = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Chip(
                      label: Text(review.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                      backgroundColor: review.status == 'PUBLISHED' ? Colors.green : review.status == 'APPROVED' ? Colors.blue : Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Customer: ${review.customerName ?? 'Anonymous'} | Duration: ${review.videoDuration}s'),
                Text('Recorded: ${DateFormat('dd MMM yyyy, hh:mm a').format(review.createdAt)}', style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                const SizedBox(height: 12),

                // Action Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isPending) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(100, 36)),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve', style: TextStyle(fontSize: 12)),
                        onPressed: () => _approve(review.id),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(100, 36)),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject', style: TextStyle(fontSize: 12)),
                        onPressed: () => _reject(review.id),
                      ),
                    ],
                    if (isApproved) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(100, 36)),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit Details', style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final res = await Get.to(() => AdminVideoEditorScreen(review: review));
                          if (res == true) _fetchReviews();
                        },
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(110, 36)),
                        icon: const Icon(Icons.video_collection, size: 16),
                        label: const Text('Publish YT', style: TextStyle(fontSize: 12)),
                        onPressed: () => _publishYouTube(review.id),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, minimumSize: const Size(110, 36)),
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text('Publish IG', style: TextStyle(fontSize: 12)),
                        onPressed: () => _publishInstagram(review.id),
                      ),
                    ],
                    if (isPublished) ...[
                      if (review.youtubeVideoUrl != null)
                        Text('YouTube: ${review.youtubeVideoUrl}', style: const TextStyle(fontSize: 11, color: Colors.blue)),
                      if (review.instagramVideoUrl != null)
                        Text('Instagram: ${review.instagramVideoUrl}', style: const TextStyle(fontSize: 11, color: Colors.purple)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
