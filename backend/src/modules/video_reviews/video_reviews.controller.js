const VideoReviewsService = require('./video_reviews.service');
const { ApiError } = require('../../middleware/errorHandler');

class VideoReviewsController {
  static async uploadVideoFile(req, res, next) {
    try {
      if (!req.file) {
        throw new ApiError(400, 'No video file provided');
      }
      const videoUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
      res.status(200).json({
        success: true,
        message: 'Video file uploaded successfully',
        data: {
          videoUrl,
          filename: req.file.filename,
          size: req.file.size,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  static async createVideoReview(req, res, next) {
    try {
      const review = await VideoReviewsService.createVideoReview(req.user.id, req.body);
      res.status(201).json({
        success: true,
        message: 'Customer video review submitted successfully (Pending Admin Approval)',
        data: review,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getReviews(req, res, next) {
    try {
      const reviews = await VideoReviewsService.getReviews(req.user.role, req.user.id, req.query.status);
      res.status(200).json({
        success: true,
        data: reviews,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getReviewById(req, res, next) {
    try {
      const review = await VideoReviewsService.getReviewById(req.params.id);
      res.status(200).json({
        success: true,
        data: review,
      });
    } catch (error) {
      next(error);
    }
  }

  static async approveReview(req, res, next) {
    try {
      const updated = await VideoReviewsService.approveReview(req.user.id, req.params.id);
      res.status(200).json({
        success: true,
        message: 'Video review approved successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async rejectReview(req, res, next) {
    try {
      const updated = await VideoReviewsService.rejectReview(req.user.id, req.params.id, req.body.rejectionReason);
      res.status(200).json({
        success: true,
        message: 'Video review rejected',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async editReview(req, res, next) {
    try {
      const updated = await VideoReviewsService.editReview(req.user.id, req.params.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Video review details updated successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async deleteReview(req, res, next) {
    try {
      const result = await VideoReviewsService.deleteReview(req.params.id);
      res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  static async publishToYouTube(req, res, next) {
    try {
      const updated = await VideoReviewsService.publishToYouTube(req.user.id, req.params.id);
      res.status(200).json({
        success: true,
        message: 'Video published to YouTube Shorts successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async publishToInstagram(req, res, next) {
    try {
      const updated = await VideoReviewsService.publishToInstagram(req.user.id, req.params.id);
      res.status(200).json({
        success: true,
        message: 'Video published to Instagram Reels successfully',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getSocialAccounts(req, res, next) {
    try {
      const accounts = await VideoReviewsService.getSocialAccounts();
      res.status(200).json({
        success: true,
        data: accounts,
      });
    } catch (error) {
      next(error);
    }
  }

  static async connectSocialAccount(req, res, next) {
    try {
      const { platform, accountDisplayName, connectedAccountId } = req.body;
      const account = await VideoReviewsService.connectSocialAccount(platform, accountDisplayName, connectedAccountId);
      res.status(200).json({
        success: true,
        message: `Successfully connected to ${platform}`,
        data: account,
      });
    } catch (error) {
      next(error);
    }
  }

  static async disconnectSocialAccount(req, res, next) {
    try {
      const result = await VideoReviewsService.disconnectSocialAccount(req.params.platform);
      res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = VideoReviewsController;
