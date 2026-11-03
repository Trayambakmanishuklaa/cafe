import 'package:dio/dio.dart';
import '../../app/core/network/api_client.dart';
import '../models/video_review_model.dart';

class VideoReviewRepository {
  final ApiClient _apiClient;

  VideoReviewRepository(this._apiClient);

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData is Map) {
      final data = responseData['data'];
      if (data is List) return data;
    }
    if (responseData is List) return responseData;
    return [];
  }

  Map<String, dynamic> _extractMap(dynamic responseData) {
    if (responseData is Map) {
      final data = responseData['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return Map<String, dynamic>.from(responseData);
    }
    return {};
  }

  Future<String> uploadVideoFile(String filePath) async {
    final formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(filePath, filename: 'review_video.mp4'),
    });
    final res = await _apiClient.post('/video-reviews/upload', data: formData);
    final map = _extractMap(res.data);
    return map['videoUrl']?.toString() ?? '';
  }

  Future<List<VideoReviewModel>> getReviews({String? status}) async {
    final res = await _apiClient.get('/video-reviews', queryParameters: status != null ? {'status': status} : null);
    final list = _extractList(res.data);
    return list.map((e) => VideoReviewModel.fromJson(e)).toList();
  }

  Future<VideoReviewModel> createReview({
    String? customerName,
    String? productId,
    required String productName,
    required String originalVideoUrl,
    String? thumbnailUrl,
    int videoDuration = 15,
    required bool consentStatus,
  }) async {
    final res = await _apiClient.post('/video-reviews', data: {
      'customerName': customerName,
      'productId': productId,
      'productName': productName,
      'originalVideoUrl': originalVideoUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoDuration': videoDuration,
      'consentStatus': consentStatus,
    });
    return VideoReviewModel.fromJson(_extractMap(res.data));
  }

  Future<void> approveReview(String id) async {
    await _apiClient.patch('/video-reviews/$id/approve');
  }

  Future<void> rejectReview(String id, String reason) async {
    await _apiClient.patch('/video-reviews/$id/reject', data: {'rejectionReason': reason});
  }

  Future<void> editReview(String id, {String? title, String? description, String? hashtags, String? editedVideoUrl}) async {
    await _apiClient.patch('/video-reviews/$id/edit', data: {
      'title': title,
      'description': description,
      'hashtags': hashtags,
      'editedVideoUrl': editedVideoUrl,
    });
  }

  Future<void> publishToYouTube(String id) async {
    await _apiClient.post('/video-reviews/$id/publish/youtube');
  }

  Future<void> publishToInstagram(String id) async {
    await _apiClient.post('/video-reviews/$id/publish/instagram');
  }

  Future<List<dynamic>> getSocialAccounts() async {
    final res = await _apiClient.get('/video-reviews/social/accounts');
    return _extractList(res.data);
  }

  Future<void> connectSocialAccount(String platform, String accountDisplayName, String connectedAccountId) async {
    await _apiClient.post('/video-reviews/social/accounts/connect', data: {
      'platform': platform,
      'accountDisplayName': accountDisplayName,
      'connectedAccountId': connectedAccountId,
    });
  }
}
