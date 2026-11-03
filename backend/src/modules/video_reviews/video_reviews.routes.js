const express = require('express');
const multer = require('multer');
const path = require('path');
const VideoReviewsController = require('./video_reviews.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../../../uploads');
    const fs = require('fs');
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'review-' + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only video files are allowed!'), false);
    }
  },
});

// Staff routes
router.post('/upload', authenticate, authorize('STAFF', 'OWNER', 'ADMIN'), upload.single('video'), VideoReviewsController.uploadVideoFile);
router.post('/', authenticate, authorize('STAFF', 'OWNER', 'ADMIN'), VideoReviewsController.createVideoReview);

// General / Shared review routes
router.get('/', authenticate, VideoReviewsController.getReviews);
router.get('/:id', authenticate, VideoReviewsController.getReviewById);

// Admin review & publishing routes
router.patch('/:id/approve', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.approveReview);
router.patch('/:id/reject', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.rejectReview);
router.patch('/:id/edit', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.editReview);
router.delete('/:id', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.deleteReview);
router.post('/:id/publish/youtube', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.publishToYouTube);
router.post('/:id/publish/instagram', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.publishToInstagram);

// Social Media Accounts routes
router.get('/social/accounts', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.getSocialAccounts);
router.post('/social/accounts/connect', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.connectSocialAccount);
router.delete('/social/accounts/:platform', authenticate, authorize('ADMIN', 'OWNER'), VideoReviewsController.disconnectSocialAccount);

module.exports = router;
