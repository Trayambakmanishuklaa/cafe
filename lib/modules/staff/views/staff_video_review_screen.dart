import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/core/errors/error_utils.dart';
import '../../../app/core/network/api_client.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../data/models/video_review_model.dart';
import '../../../data/repositories/video_review_repository.dart';

class StaffVideoReviewScreen extends StatefulWidget {
  const StaffVideoReviewScreen({super.key});

  @override
  State<StaffVideoReviewScreen> createState() => _StaffVideoReviewScreenState();
}

class _StaffVideoReviewScreenState extends State<StaffVideoReviewScreen> {
  final VideoReviewRepository _repo = VideoReviewRepository(Get.find<ApiClient>());

  List<VideoReviewModel> _reviews = [];
  bool _isLoading = true;

  // New Review Form state
  final _customerNameController = TextEditingController();
  String _selectedProduct = 'Masala Chai';
  bool _consentAgreed = false;
  bool _isRecording = false;
  bool _hasRecordedVideo = false;
  bool _isUploading = false;
  int _recordingSeconds = 0;

  final List<String> _cafeProducts = [
    'Masala Chai',
    'Adrak Elaichi Chai',
    'Espresso',
    'Cappuccino',
    'Cold Coffee',
    'Maska Bun',
    'Cheese Bun',
    'Crispy Aloo Burger',
    'Paneer Makhani Burger',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMyReviews();
  }

  Future<void> _fetchMyReviews() async {
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

  void _startMockRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    // Simulate 15 second portrait video recording
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isRecording) {
        setState(() {
          _isRecording = false;
          _hasRecordedVideo = true;
          _recordingSeconds = 15;
        });
      }
    });
  }

  Future<void> _submitReview() async {
    if (!_consentAgreed) {
      Get.snackbar('Consent Required', 'Mandatory customer consent confirmation is required before submitting review.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      return;
    }

    if (!_hasRecordedVideo) {
      Get.snackbar('Video Missing', 'Please record a short video review first.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      return;
    }

    setState(() => _isUploading = true);
    try {
      await _repo.createReview(
        customerName: _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
        productName: _selectedProduct,
        originalVideoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        thumbnailUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=400&q=80',
        videoDuration: _recordingSeconds > 0 ? _recordingSeconds : 15,
        consentStatus: true,
      );

      Get.back(); // close modal
      _customerNameController.clear();
      setState(() {
        _hasRecordedVideo = false;
        _consentAgreed = false;
      });

      Get.snackbar('Success!', 'Video review submitted securely. Status: PENDING_ADMIN_APPROVAL',
          backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
      _fetchMyReviews();
    } catch (e) {
      Get.snackbar('Upload Failed', ErrorUtils.getCleanMessage(e));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showRecordModal(BuildContext context) {
    _customerNameController.clear();
    setState(() {
      _consentAgreed = false;
      _hasRecordedVideo = false;
      _isRecording = false;
    });

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎥 Record Customer Video Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),

                  // Product Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    decoration: const InputDecoration(labelText: 'Related Cafe Product'),
                    items: _cafeProducts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setModalState(() => _selectedProduct = val ?? _selectedProduct),
                  ),
                  const SizedBox(height: 12),

                  // Customer Name
                  TextField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(labelText: 'Customer Name (Optional)'),
                  ),
                  const SizedBox(height: 16),

                  // Recording Box / Preview
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _isRecording
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppLoader(size: 50),
                                const SizedBox(height: 10),
                                Text('Recording Portrait Video... 15s', style: TextStyle(color: Colors.white70)),
                              ],
                            )
                          : _hasRecordedVideo
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                                    SizedBox(height: 8),
                                    Text('Video Recorded Successfully (15s)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                )
                              : IconButton(
                                  icon: const Icon(Icons.fiber_manual_record, color: Colors.red, size: 64),
                                  onPressed: () {
                                    setModalState(() => _isRecording = true);
                                    _startMockRecording();
                                    Future.delayed(const Duration(seconds: 15), () {
                                      if (mounted) {
                                        setModalState(() {
                                          _isRecording = false;
                                          _hasRecordedVideo = true;
                                          _recordingSeconds = 15;
                                        });
                                      }
                                    });
                                  },
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mandatory Consent Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F4EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.secondary.withAlpha(120)),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _consentAgreed,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setModalState(() => _consentAgreed = val ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            '"I voluntarily agree to have my video, face, and voice recorded for the cafe promotional content."',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isUploading ? null : _submitReview,
                    child: _isUploading
                        ? const AppLoader(size: 28)
                        : const Text('SUBMIT FOR ADMIN APPROVAL'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff - Customer Video Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMyReviews,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.videocam),
        label: const Text('Record Review'),
        onPressed: () => _showRecordModal(context),
      ),
      body: _isLoading
          ? const AppLoader()
          : _reviews.isEmpty
              ? const Center(
                  child: Text('No customer video reviews recorded yet.\nTap "Record Review" to start.', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
                        ),
                        title: Text(review.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Customer: ${review.customerName ?? 'Anonymous'}\nStatus: ${review.status}'),
                        trailing: Chip(
                          label: Text(review.status, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: review.status == 'APPROVED' || review.status == 'PUBLISHED'
                              ? Colors.green
                              : review.status == 'REJECTED'
                                  ? Colors.red
                                  : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
