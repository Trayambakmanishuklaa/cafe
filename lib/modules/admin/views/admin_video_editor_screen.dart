import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/video_review_model.dart';
import '../../../data/repositories/video_review_repository.dart';

class AdminVideoEditorScreen extends StatefulWidget {
  final VideoReviewModel review;
  const AdminVideoEditorScreen({super.key, required this.review});

  @override
  State<AdminVideoEditorScreen> createState() => _AdminVideoEditorScreenState();
}

class _AdminVideoEditorScreenState extends State<AdminVideoEditorScreen> {
  final VideoReviewRepository _repo = VideoReviewRepository(Get.find<ApiClient>());

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _hashtagsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.review.title ?? 'Amazing ${widget.review.productName} at Shubh\'s Cafe! ☕🔥');
    _descController = TextEditingController(text: widget.review.description ?? 'Our wonderful customer sharing their love for ${widget.review.productName}. Good food, good mood!');
    _hashtagsController = TextEditingController(text: widget.review.hashtags ?? '#ShubhsCafe #${widget.review.productName.replaceAll(' ', '')} #CafeVibes #Foodie');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await _repo.editReview(
        widget.review.id,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        hashtags: _hashtagsController.text.trim(),
      );
      Get.back(result: true);
      Get.snackbar('Saved!', 'Video details edited and prepared for publishing',
          backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
    } catch (e) {
      Get.snackbar('Save Failed', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin - Video Editor & Branding'),
      ),
      body: SingleChildScrollView(
        padding: AppResponsive.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Video Title (Shorts / Reels Title)'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Caption & Description'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _hashtagsController,
              decoration: const InputDecoration(labelText: 'Hashtags'),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const AppLoader(size: 28)
                  : const Text('SAVE EDITED VERSION'),
            ),
          ],
        ),
      ),
    );
  }
}
