import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

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
  final ImagePicker _picker = ImagePicker();

  List<VideoReviewModel> _reviews = [];
  bool _isLoading = true;

  // Form state
  final _customerNameController = TextEditingController();
  String _selectedProduct = 'Masala Chai';
  bool _consentAgreed = false;
  String? _recordedVideoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatusText = '';

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

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _customerNameController.dispose();
    super.dispose();
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

  Future<void> _recordVideoWithCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video != null) {
        setState(() {
          _recordedVideoPath = video.path;
        });

        _videoPlayerController?.dispose();
        _videoPlayerController = VideoPlayerController.file(File(video.path));
        await _videoPlayerController!.initialize();
        _videoPlayerController!.setLooping(true);
        _videoPlayerController!.play();
        setState(() {});
      }
    } catch (e) {
      Get.snackbar('Camera Error', ErrorUtils.getCleanMessage(e));
    }
  }

  void _retakeVideo() {
    _videoPlayerController?.dispose();
    setState(() {
      _recordedVideoPath = null;
      _videoPlayerController = null;
    });
  }

  Future<void> _submitVideoReview(StateSetter setModalState) async {
    if (!_consentAgreed) {
      Get.snackbar('Consent Required', 'Mandatory customer consent confirmation is required before submitting review.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      return;
    }

    if (_recordedVideoPath == null || !File(_recordedVideoPath!).existsSync()) {
      Get.snackbar('Video Missing', 'Please record a valid video review using the camera first.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      return;
    }

    setModalState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatusText = 'Preparing video...';
    });
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatusText = 'Preparing video...';
    });

    try {
      // 1. Upload video file to backend with progress indicator
      final videoUrl = await _repo.uploadVideoFile(
        _recordedVideoPath!,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            final percent = (progress * 100).toStringAsFixed(0);
            setModalState(() {
              _uploadProgress = progress;
              _uploadStatusText = 'Uploading video... $percent%';
            });
            setState(() {
              _uploadProgress = progress;
              _uploadStatusText = 'Uploading video... $percent%';
            });
          }
        },
      );

      setModalState(() {
        _uploadStatusText = 'Saving review details...';
      });
      setState(() {
        _uploadStatusText = 'Saving review details...';
      });

      // 2. Submit review metadata
      await _repo.createReview(
        customerName: _customerNameController.text.trim().isEmpty ? null : _customerNameController.text.trim(),
        productName: _selectedProduct,
        originalVideoUrl: videoUrl,
        thumbnailUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=400&q=80',
        videoDuration: 15,
        consentStatus: true,
      );

      Get.back(); // close sheet
      _customerNameController.clear();
      _retakeVideo();

      Get.snackbar('Success!', 'Real video uploaded and submitted for Admin approval!',
          backgroundColor: Colors.green.withAlpha(35), colorText: Colors.green);
      _fetchMyReviews();
    } catch (e) {
      Get.snackbar('Upload Failed', ErrorUtils.getCleanMessage(e));
    } finally {
      setModalState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadStatusText = '';
      });
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _uploadStatusText = '';
      });
    }
  }

  void _showRecordModal(BuildContext context) {
    _customerNameController.clear();
    setState(() {
      _consentAgreed = false;
      _recordedVideoPath = null;
      _videoPlayerController = null;
      _isUploading = false;
      _uploadProgress = 0.0;
      _uploadStatusText = '';
    });

    Get.bottomSheet(
      PopScope(
        canPop: !_isUploading,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('🎥 Record Customer Video Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: _selectedProduct,
                        decoration: const InputDecoration(labelText: 'Related Cafe Product'),
                        items: _cafeProducts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: _isUploading ? null : (val) => setModalState(() => _selectedProduct = val ?? _selectedProduct),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: _customerNameController,
                        enabled: !_isUploading,
                        decoration: const InputDecoration(labelText: 'Customer Name (Optional)'),
                      ),
                      const SizedBox(height: 14),

                      // Video Preview or Record Button
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: Colors.black,
                            child: _recordedVideoPath != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                                        child: VideoPlayer(_videoPlayerController!),
                                      ),
                                      if (!_isUploading)
                                        Positioned(
                                          bottom: 16,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Retake Video'),
                                            onPressed: () {
                                              setModalState(() {
                                                _retakeVideo();
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  )
                                : Center(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      ),
                                      icon: const Icon(Icons.videocam, size: 28),
                                      label: const Text('Open Camera & Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      onPressed: _isUploading
                                          ? null
                                          : () async {
                                              await _recordVideoWithCamera();
                                              setModalState(() {});
                                            },
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Mandatory Consent Checkbox
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4EC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondary.withAlpha(120)),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _consentAgreed,
                              activeColor: AppColors.primary,
                              onChanged: _isUploading ? null : (val) => setModalState(() => _consentAgreed = val ?? false),
                            ),
                            const Expanded(
                              child: Text(
                                '"I voluntarily agree to have my video, face, and voice recorded for promotional content and social sharing."',
                                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      ElevatedButton(
                        onPressed: _isUploading || _recordedVideoPath == null
                            ? null
                            : () => _submitVideoReview(setModalState),
                        child: _isUploading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  ),
                                  SizedBox(width: 10),
                                  Text('UPLOADING...'),
                                ],
                              )
                            : const Text('UPLOAD & SUBMIT VIDEO'),
                      ),
                    ],
                  ),

                  // Full-screen Loading Overlay inside bottom sheet
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(245),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppLoader(size: 80),
                            const SizedBox(height: 20),
                            Text(
                              _uploadStatusText.isEmpty ? 'Uploading video, please wait...' : _uploadStatusText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _uploadProgress > 0 ? _uploadProgress : null,
                                  backgroundColor: Colors.grey.shade200,
                                  color: AppColors.primary,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Uploading review video to server.\nPlease stay on this screen.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    ).then((_) {
      _videoPlayerController?.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff - Real Video Reviews'),
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
        label: const Text('Record Real Video'),
        onPressed: () => _showRecordModal(context),
      ),
      body: _isLoading
          ? const AppLoader()
          : _reviews.isEmpty
              ? const Center(
                  child: Text('No real video reviews recorded yet.\nTap "Record Real Video" to start.', textAlign: TextAlign.center),
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
