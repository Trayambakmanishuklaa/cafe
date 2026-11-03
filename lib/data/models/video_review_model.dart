import 'dart:convert';

class VideoReviewModel {
  final String id;
  final String staffId;
  final Map<String, dynamic>? staff;
  final String? customerName;
  final String? productId;
  final String productName;
  final String originalVideoUrl;
  final String? editedVideoUrl;
  final String? thumbnailUrl;
  final int videoDuration;
  final bool consentStatus;
  final String status; // PENDING_ADMIN_APPROVAL, APPROVED, REJECTED, READY_TO_PUBLISH, PUBLISHED
  final String? adminId;
  final String? rejectionReason;
  final String? title;
  final String? description;
  final String? hashtags;
  final String? youtubeVideoUrl;
  final String? youtubeStatus;
  final String? instagramVideoUrl;
  final String? instagramStatus;
  final DateTime createdAt;

  VideoReviewModel({
    required this.id,
    required this.staffId,
    this.staff,
    this.customerName,
    this.productId,
    required this.productName,
    required this.originalVideoUrl,
    this.editedVideoUrl,
    this.thumbnailUrl,
    required this.videoDuration,
    required this.consentStatus,
    required this.status,
    this.adminId,
    this.rejectionReason,
    this.title,
    this.description,
    this.hashtags,
    this.youtubeVideoUrl,
    this.youtubeStatus,
    this.instagramVideoUrl,
    this.instagramStatus,
    required this.createdAt,
  });

  factory VideoReviewModel.fromJson(dynamic json) {
    if (json is! Map) {
      return VideoReviewModel(
        id: '',
        staffId: '',
        productName: '',
        originalVideoUrl: '',
        videoDuration: 15,
        consentStatus: false,
        status: 'PENDING_ADMIN_APPROVAL',
        createdAt: DateTime.now(),
      );
    }
    final map = Map<String, dynamic>.from(json);
    return VideoReviewModel(
      id: map['id']?.toString() ?? '',
      staffId: map['staffId']?.toString() ?? '',
      staff: map['staff'] is Map ? Map<String, dynamic>.from(map['staff']) : null,
      customerName: map['customerName']?.toString(),
      productId: map['productId']?.toString(),
      productName: map['productName']?.toString() ?? '',
      originalVideoUrl: map['originalVideoUrl']?.toString() ?? '',
      editedVideoUrl: map['editedVideoUrl']?.toString(),
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      videoDuration: int.tryParse(map['videoDuration']?.toString() ?? '15') ?? 15,
      consentStatus: map['consentStatus'] == true,
      status: map['status']?.toString() ?? 'PENDING_ADMIN_APPROVAL',
      adminId: map['adminId']?.toString(),
      rejectionReason: map['rejectionReason']?.toString(),
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      hashtags: map['hashtags']?.toString(),
      youtubeVideoUrl: map['youtubeVideoUrl']?.toString(),
      youtubeStatus: map['youtubeStatus']?.toString(),
      instagramVideoUrl: map['instagramVideoUrl']?.toString(),
      instagramStatus: map['instagramStatus']?.toString(),
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'customerName': customerName,
      'productId': productId,
      'productName': productName,
      'originalVideoUrl': originalVideoUrl,
      'editedVideoUrl': editedVideoUrl,
      'thumbnailUrl': thumbnailUrl,
      'videoDuration': videoDuration,
      'consentStatus': consentStatus,
      'status': status,
      'adminId': adminId,
      'rejectionReason': rejectionReason,
      'title': title,
      'description': description,
      'hashtags': hashtags,
      'youtubeVideoUrl': youtubeVideoUrl,
      'youtubeStatus': youtubeStatus,
      'instagramVideoUrl': instagramVideoUrl,
      'instagramStatus': instagramStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
