const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class LoyaltyService {
  static async getPassport(userId) {
    const account = await prisma.loyaltyAccount.findUnique({
      where: { userId },
      include: {
        transactions: {
          orderBy: { createdAt: 'desc' },
          take: 10,
        },
      },
    });

    const achievements = await prisma.customerAchievement.findMany({
      where: { userId },
      include: { achievement: true },
    });

    const activeRedemptions = await prisma.rewardRedemption.findMany({
      where: { userId, status: 'ACTIVE' },
      include: { reward: true },
    });

    const profile = await prisma.customerProfile.findUnique({
      where: { userId },
    });

    return {
      account,
      profile,
      achievements,
      activeRedemptions,
    };
  }

  static async getRewards() {
    return await prisma.reward.findMany({
      where: { isActive: true },
      orderBy: { pointsCost: 'asc' },
    });
  }

  static async redeemReward(userId, rewardId) {
    const reward = await prisma.reward.findUnique({
      where: { id: rewardId },
    });

    if (!reward || !reward.isActive) {
      throw new ApiError(404, 'Reward not available for redemption');
    }

    return await prisma.$transaction(async (tx) => {
      const account = await tx.loyaltyAccount.findUnique({
        where: { userId },
      });

      if (!account || account.pointsBalance < reward.pointsCost) {
        throw new ApiError(400, 'Insufficient loyalty points to redeem this reward');
      }

      // Deduct points
      const updatedAccount = await tx.loyaltyAccount.update({
        where: { id: account.id },
        data: {
          pointsBalance: { decrement: reward.pointsCost },
        },
      });

      // Write append-only transaction ledger entry
      await tx.loyaltyTransaction.create({
        data: {
          loyaltyAccountId: account.id,
          type: 'REDEEM',
          points: -reward.pointsCost,
          description: `Redeemed reward: ${reward.title}`,
        },
      });

      // Create reward redemption voucher code
      const voucherCode = `RWD-${Date.now().toString().slice(-4)}-${Math.floor(1000 + Math.random() * 9000)}`;
      const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days validity

      const redemption = await tx.rewardRedemption.create({
        data: {
          userId,
          rewardId: reward.id,
          code: voucherCode,
          status: 'ACTIVE',
          expiresAt,
        },
        include: { reward: true },
      });

      return {
        redemption,
        remainingPoints: updatedAccount.pointsBalance,
      };
    });
  }
}

module.exports = LoyaltyService;
