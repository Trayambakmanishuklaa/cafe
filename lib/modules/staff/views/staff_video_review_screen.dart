import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';

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

  // Form & Camera state
  final _customerNameController = TextEditingController();
  String _selectedProduct = 'Masala Chai';
  bool _consentAgreed = false;

  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  String? _recordedVideoPath;
  VideoPlayerController? _videoPlayerController;
  bool _isPlayingPreview = false;
  bool _isUploading = false;

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
    _cameraController?.dispose();
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

  Future<void> _initCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      Get.snackbar('Permission Denied', 'Camera and microphone permissions are required to record video reviews.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        Get.snackbar('Error', 'No cameras found on device');
        return;
      }

      // Default to rear camera or first available
      _cameraController = CameraController(_cameras[0], ResolutionPreset.medium, enableAudio: true);
      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      Get.snackbar('Camera Error', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_isRecording) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);

      // Auto stop after 20 seconds for short review
      Future.delayed(const Duration(seconds: 20), () {
        if (mounted && _isRecording) {
          _stopRecording();
        }
      });
    } catch (e) {
      Get.snackbar('Recording Error', ErrorUtils.getCleanMessage(e));
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;

    try {
      final file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordedVideoPath = file.path;
      });

      // Initialize video player for preview
      _videoPlayerController = VideoPlayerController.file(File(file.path));
      await _videoPlayerController!.initialize();
      _videoPlayerController!.setLooping(true);
      _videoPlayerController!.play();
      setState(() => _isPlayingPreview = true);
    } catch (e) {
      Get.snackbar('Stop Error', ErrorUtils.getCleanMessage(e));
    }
  }

  void _retakeVideo() {
    _videoPlayerController?.dispose();
    setState(() {
      _recordedVideoPath = null;
      _videoPlayerController = null;
      _isPlayingPreview = false;
    });
  }

  Future<void> _submitVideoReview() async {
    if (!_consentAgreed) {
      Get.snackbar('Consent Required', 'Mandatory customer consent confirmation is required before submitting review.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      return;
    }

    if (_recordedVideoPath == null || !File(_recordedVideoPath!).existsSync()) {
      Get.snackbar('Video Missing', 'Please record a valid video review first.',
          backgroundColor: Colors.red.withAlpha(35), colorText: Colors.red);
      return;
    }

    setState(() => _isUploading = true);
    try {
      // 1. Upload actual video file to backend
      final videoUrl = await _repo.uploadVideoFile(_recordedVideoPath!);

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
      setState(() => _isUploading = false);
    }
  }

  void _showRecordModal(BuildContext context) {
    _customerNameController.clear();
    setState(() {
      _consentAgreed = false;
      _recordedVideoPath = null;
      _isCameraInitialized = false;
    });
    _initCamera();

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('🎥 Real Camera Video Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(labelText: 'Related Cafe Product'),
                  items: _cafeProducts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (val) => setModalState(() => _selectedProduct = val ?? _selectedProduct),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(labelText: 'Customer Name (Optional)'),
                ),
                const SizedBox(height: 14),

                // Camera Preview or Video Player Preview
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
                          : _isCameraInitialized && _cameraController != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CameraPreview(_cameraController!),
                                    if (_isRecording)
                                      Positioned(
                                        top: 16,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                                          child: const Text('🔴 REC (Portrait 9:16)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 16,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FloatingActionButton(
                                            backgroundColor: _isRecording ? Colors.red : Colors.white,
                                            child: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record, color: _isRecording ? Colors.white : Colors.red, size: 36),
                                            onPressed: () async {
                                              if (_isRecording) {
                                                await _stopRecording();
                                                setModalState(() {});
                                              } else {
                                                await _startRecording();
                                                setModalState(() {});
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const Center(child: AppLoader(size: 50)),
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
                        onChanged: (val) => setModalState(() => _consentAgreed = val ?? false),
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
                  onPressed: _isUploading || _recordedVideoPath == null ? null : _submitVideoReview,
                  child: _isUploading
                      ? const AppLoader(size: 28)
                      : const Text('UPLOAD & SUBMIT VIDEO'),
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    ).then((_) {
      _cameraController?.dispose();
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
