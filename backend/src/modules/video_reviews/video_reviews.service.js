const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class VideoReviewsService {
  static async createVideoReview(staffId, data) {
    const { customerName, productId, productName, originalVideoUrl, thumbnailUrl, videoDuration, consentStatus } = data;

    if (!originalVideoUrl || !productName) {
      throw new ApiError(400, 'Original video URL and product name are required');
    }

    if (!consentStatus) {
      throw new ApiError(400, 'Mandatory customer consent is required to record and submit a video review');
    }

    const review = await prisma.customerVideoReview.create({
      data: {
        staffId,
        customerName: customerName || null,
        productId: productId || null,
        productName,
        originalVideoUrl,
        thumbnailUrl: thumbnailUrl || null,
        videoDuration: Number(videoDuration) || 15,
        consentStatus: true,
        consentTimestamp: new Date(),
        status: 'PENDING_ADMIN_APPROVAL',
      },
      include: {
        staff: { select: { id: true, name: true, email: true, phone: true } },
      },
    });

    return review;
  }

  static async getReviews(queryRole, userId, status) {
    const where = {};
    if (queryRole === 'STAFF') {
      where.staffId = userId;
    }
    if (status) {
      where.status = status;
    }

    const reviews = await prisma.customerVideoReview.findMany({
      where,
      include: {
        staff: { select: { id: true, name: true, phone: true } },
        admin: { select: { id: true, name: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    return reviews;
  }

  static async getReviewById(id) {
    const review = await prisma.customerVideoReview.findUnique({
      where: { id },
      include: {
        staff: { select: { id: true, name: true, phone: true } },
        admin: { select: { id: true, name: true } },
      },
    });

    if (!review) {
      throw new ApiError(404, 'Video review not found');
    }

    return review;
  }

  static async approveReview(adminId, id) {
    const review = await this.getReviewById(id);

    const updated = await prisma.customerVideoReview.update({
      where: { id },
      data: {
        status: 'APPROVED',
        adminId,
      },
    });

    return updated;
  }

  static async rejectReview(adminId, id, rejectionReason) {
    const review = await this.getReviewById(id);

    const updated = await prisma.customerVideoReview.update({
      where: { id },
      data: {
        status: 'REJECTED',
        adminId,
        rejectionReason: rejectionReason || 'Does not meet review standards',
      },
    });

    return updated;
  }

  static async editReview(adminId, id, data) {
    await this.getReviewById(id);
    const { title, description, hashtags, editedVideoUrl, thumbnailUrl } = data;

    const updated = await prisma.customerVideoReview.update({
      where: { id },
      data: {
        title,
        description,
        hashtags,
        editedVideoUrl,
        thumbnailUrl,
        adminId,
        status: 'READY_TO_PUBLISH',
      },
    });

    return updated;
  }

  static async deleteReview(id) {
    await this.getReviewById(id);
    await prisma.customerVideoReview.delete({ where: { id } });
    return { message: 'Video review deleted successfully' };
  }

  static async publishToYouTube(adminId, id) {
    const review = await this.getReviewById(id);
    if (review.status !== 'APPROVED' && review.status !== 'READY_TO_PUBLISH') {
      throw new ApiError(400, 'Video must be approved before publishing');
    }

    const mockYouTubeId = `yt_${Date.now()}`;
    const mockYouTubeUrl = `https://youtube.com/shorts/${mockYouTubeId}`;

    const updated = await prisma.customerVideoReview.update({
      where: { id },
      data: {
        youtubeVideoId: mockYouTubeId,
        youtubeVideoUrl: mockYouTubeUrl,
        youtubeStatus: 'PUBLISHED',
        status: 'PUBLISHED',
        adminId,
      },
    });

    return updated;
  }

  static async publishToInstagram(adminId, id) {
    const review = await this.getReviewById(id);
    if (review.status !== 'APPROVED' && review.status !== 'READY_TO_PUBLISH') {
      throw new ApiError(400, 'Video must be approved before publishing');
    }

    const mockInstagramMediaId = `ig_${Date.now()}`;
    const mockInstagramUrl = `https://instagram.com/reel/${mockInstagramMediaId}`;

    const updated = await prisma.customerVideoReview.update({
      where: { id },
      data: {
        instagramMediaId: mockInstagramMediaId,
        instagramVideoUrl: mockInstagramUrl,
        instagramStatus: 'PUBLISHED',
        status: 'PUBLISHED',
        adminId,
      },
    });

    return updated;
  }

  static async getSocialAccounts() {
    return await prisma.socialMediaAccount.findMany();
  }

  static async connectSocialAccount(platform, accountDisplayName, connectedAccountId) {
    const account = await prisma.socialMediaAccount.upsert({
      where: { platform },
      update: {
        accountDisplayName,
        connectedAccountId,
        connectionStatus: 'CONNECTED',
        lastConnectedAt: new Date(),
      },
      create: {
        platform,
        accountDisplayName,
        connectedAccountId,
        connectionStatus: 'CONNECTED',
      },
    });
    return account;
  }

  static async disconnectSocialAccount(platform) {
    await prisma.socialMediaAccount.updateMany({
      where: { platform },
      data: { connectionStatus: 'DISCONNECTED' },
    });
    return { message: `Disconnected platform ${platform}` };
  }
}

module.exports = VideoReviewsService;
