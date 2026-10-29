const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class CustomersService {
  static async getCustomerList({ search, tier }) {
    const where = { role: 'CUSTOMER' };

    if (search) {
      where.OR = [
        { name: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search, mode: 'insensitive' } },
      ];
    }

    const customers = await prisma.user.findMany({
      where,
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        createdAt: true,
        profile: true,
        loyaltyAccount: true,
        _count: {
          select: {
            orders: true,
            bookings: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    if (tier) {
      return customers.filter((c) => c.loyaltyAccount?.tier === tier);
    }

    return customers;
  }

  static async getCustomerDetails(customerId) {
    const user = await prisma.user.findUnique({
      where: { id: customerId },
      include: {
        profile: true,
        loyaltyAccount: {
          include: {
            transactions: {
              orderBy: { createdAt: 'desc' },
            },
          },
        },
        orders: {
          include: { items: true },
          orderBy: { createdAt: 'desc' },
        },
        bookings: {
          include: { table: true },
          orderBy: { createdAt: 'desc' },
        },
        rewardRedemptions: {
          include: { reward: true },
        },
        feedbacks: true,
      },
    });

    if (!user) {
      throw new ApiError(404, 'Customer account not found');
    }

    return user;
  }

  static async adjustPoints(customerId, { points, description }, actorUserId) {
    const account = await prisma.loyaltyAccount.findUnique({
      where: { userId: customerId },
    });

    if (!account) {
      throw new ApiError(404, 'Customer loyalty account not found');
    }

    return await prisma.$transaction(async (tx) => {
      const updatedAccount = await tx.loyaltyAccount.update({
        where: { id: account.id },
        data: {
          pointsBalance: { increment: points },
          lifetimePoints: points > 0 ? { increment: points } : undefined,
        },
      });

      await tx.loyaltyTransaction.create({
        data: {
          loyaltyAccountId: account.id,
          type: 'MANUAL_ADJUSTMENT',
          points,
          description: description || 'Manual Adjustment by Owner',
        },
      });

      await tx.auditLog.create({
        data: {
          actorUserId,
          action: 'MANUAL_POINTS_ADJUSTMENT',
          entityName: 'LoyaltyAccount',
          entityId: account.id,
          detailsJson: JSON.stringify({ points, description }),
        },
      });

      return updatedAccount;
    });
  }
}

module.exports = CustomersService;
