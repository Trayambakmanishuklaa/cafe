# Implementation Plan - Cafe Customer Video Reviews & Social Media Integration

This plan outlines the implementation of the Customer Video Review Management System with Staff video recording (mandatory consent), Admin approval workflow, video trimming/branding editor, YouTube Shorts & Instagram Reels API integration, manual sharing, and MongoDB schema additions.

## User Review Required

> [!IMPORTANT]
> - **Video Storage**: Videos will be uploaded securely via backend storage/upload middleware (or S3/cloud storage/local media storage) and referenced via metadata URLs in MongoDB.
> - **OAuth Flow**: YouTube Data API & Instagram Graph API OAuth credentials/tokens will be securely stored using encrypted database references in the `SocialMediaAccount` model.
> - **Consent Enforcement**: Mandatory staff confirmation of customer consent is required before any video can be submitted or approved.

## Open Questions

None. All feature specifications (staff recording, consent, admin approval, editor, YouTube/Instagram API integrations, manual sharing, lifecycle, MongoDB models, and security) are clearly defined.

## Proposed Changes

### Backend (Node.js, Express, Prisma & MongoDB)

#### [MODIFY] [schema.prisma](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/backend/prisma/schema.prisma)
- Add `CustomerVideoReview` model with fields: staffId, customerName, productId/productName, originalVideoUrl, editedVideoUrl, thumbnailUrl, videoDuration, consentStatus, consentTimestamp, consentVersion, recordingDate, status, adminId, rejectionReason, title, description, hashtags, youtubeVideoId, youtubeVideoUrl, youtubeStatus, instagramMediaId, instagramVideoUrl, instagramStatus, createdAt, updatedAt.
- Add `SocialMediaAccount` model for platform, connected account ID, account display name, status, encrypted tokens, expiry, last successful connection.
- Add `VideoAuditLog` or audit trail for recording, approval, rejection, editing, and publishing.

#### [NEW] [video_reviews.service.js](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/backend/src/modules/video_reviews/video_reviews.service.js)
- Handle staff video review creation, retrieval, admin approval/rejection, video editing metadata, YouTube publishing service, Instagram publishing service, and manual sharing utilities.

#### [NEW] [video_reviews.controller.js](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/backend/src/modules/video_reviews/video_reviews.controller.js)
- Expose Express endpoints for staff video review submission, admin review queue, approval, rejection, editing, and social media publishing/retries.

#### [NEW] [video_reviews.routes.js](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/backend/src/modules/video_reviews/video_reviews.routes.js)
- Wire up Express router with authentication and role-based authorization (`authenticate`, `authorize`).

### Frontend (Flutter & GetX)

#### [NEW] [video_review_model.dart](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/lib/data/models/video_review_model.dart)
- Data model for video reviews and metadata.

#### [NEW] [video_review_repository.dart](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/lib/data/repositories/video_review_repository.dart)
- Repository handling network requests to `/api/staff/video-reviews` and `/api/admin/video-reviews`.

#### [NEW] [staff_video_review_screen.dart](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/lib/modules/staff/views/staff_video_review_screen.dart)
- Staff interface for recording customer video reviews, selecting products, entering customer name, checking mandatory consent, previewing, and uploading.

#### [NEW] [admin_video_review_screen.dart](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/lib/modules/admin/views/admin_video_review_screen.dart)
- Admin interface for viewing pending approval, approved, rejected, and published videos, playing videos, approving, rejecting, editing, and publishing to YouTube/Instagram or sharing manually.

#### [NEW] [admin_video_editor_screen.dart](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/lib/modules/admin/views/admin_video_editor_screen.dart)
- Admin video editor for updating title, caption, hashtags, branding, and basic trimming.

#### [NEW] [social_media_settings_view.dart](file:///C:/Users/vaibhav/AndroidStudioProjects/Cafe/lib/modules/admin/views/social_media_settings_view.dart)
- First-login onboarding popup / settings screen for connecting YouTube and Instagram official accounts with Skip option.

## Verification Plan

### Automated Tests
- Build verification using `flutter build apk` and Node.js server compilation test.

### Manual Verification
- Verify Staff Panel has "Customer Video Reviews" option and recording flow with mandatory consent.
- Verify Admin Panel has review management queue with Pending Approval, Approve, Reject, Edit, and YouTube/Instagram publish capabilities.
- Verify First-login onboarding popup for social media setup with Skip behavior.
