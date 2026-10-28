const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class OrdersService {
  static async createOrder(userId, { orderType, tableId, bookingId, couponCode, items }) {
    // 1. Fetch products from DB to re-calculate prices server-side
    const productIds = items.map((i) => i.productId);
    const dbProducts = await prisma.product.findMany({
      where: { id: { in: productIds } },
    });

    const dbProductsMap = new Map(dbProducts.map((p) => [p.id, p]));

    let computedSubtotal = 0;
    const orderItemsData = [];

    for (const item of items) {
      const dbProduct = dbProductsMap.get(item.productId);
      if (!dbProduct) {
        throw new ApiError(400, `Product with ID ${item.productId} not found`);
      }
      if (!dbProduct.isAvailable || dbProduct.stockCount < item.quantity) {
        throw new ApiError(400, `Product '${dbProduct.name}' is out of stock`);
      }

      const itemSubtotal = dbProduct.price * item.quantity;
      computedSubtotal += itemSubtotal;

      orderItemsData.push({
        productId: dbProduct.id,
        productName: dbProduct.name,
        unitPrice: dbProduct.price,
        quantity: item.quantity,
        subtotal: itemSubtotal,
        customizationsJson: item.customizations ? JSON.stringify(item.customizations) : null,
      });
    }

    // 2. Validate Coupon if provided
    let discountAmount = 0;
    let validCouponId = null;

    if (couponCode) {
      const coupon = await prisma.coupon.findUnique({
        where: { code: couponCode.toUpperCase() },
      });

      if (coupon && coupon.isActive && new Date(coupon.expiresAt) > new Date()) {
        if (computedSubtotal >= coupon.minOrderAmount) {
          if (coupon.discountType === 'PERCENT') {
            discountAmount = (computedSubtotal * coupon.discountValue) / 100;
            if (coupon.maxDiscount && discountAmount > coupon.maxDiscount) {
              discountAmount = coupon.maxDiscount;
            }
          } else {
            discountAmount = coupon.discountValue;
          }
          validCouponId = coupon.id;
        }
      }
    }

    // 3. Compute Tax & Total Amount (5% GST for Cafe)
    const taxAmount = Math.round((computedSubtotal - discountAmount) * 0.05 * 100) / 100;
    const computedTotal = Math.max(0, computedSubtotal - discountAmount + taxAmount);

    const orderNumber = `ORD-${Date.now().toString().slice(-6)}-${Math.floor(1000 + Math.random() * 9000)}`;

    // 4. Create Order & Update stock in transaction
    const newOrder = await prisma.$transaction(async (tx) => {
      // Create order record
      const created = await tx.order.create({
        data: {
          orderNumber,
          userId,
          tableId: tableId || null,
          bookingId: bookingId || null,
          orderType,
          subtotal: computedSubtotal,
          discount: discountAmount,
          tax: taxAmount,
          totalAmount: computedTotal,
          items: {
            create: orderItemsData,
          },
        },
        include: {
          items: true,
        },
      });

      // Decrement product stock
      for (const item of items) {
        await tx.product.update({
          where: { id: item.productId },
          data: { stockCount: { decrement: item.quantity } },
        });
      }

      // Record Coupon Redemption if applied
      if (validCouponId) {
        await tx.couponRedemption.create({
          data: {
            couponId: validCouponId,
            userId,
            orderId: created.id,
            discountApplied: discountAmount,
          },
        });
      }

      return created;
    });

    return newOrder;
  }

  static async getMyOrders(userId) {
    return await prisma.order.findMany({
      where: { userId },
      include: {
        items: true,
        payments: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  static async getOrderById(orderId, userId, role) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        items: true,
        payments: true,
        user: { select: { name: true, phone: true, email: true } },
      },
    });

    if (!order) {
      throw new ApiError(404, 'Order not found');
    }

    if (role === 'CUSTOMER' && order.userId !== userId) {
      throw new ApiError(403, 'Access denied to this order');
    }

    return order;
  }

  static async getAllStaffOrders({ status }) {
    const where = {};
    if (status) {
      where.status = status;
    }

    return await prisma.order.findMany({
      where,
      include: {
        items: true,
        user: { select: { name: true, phone: true } },
        table: { select: { tableNumber: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  static async updateOrderStatus(orderId, newStatus, staffUserId) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { user: true },
    });

    if (!order) {
      throw new ApiError(404, 'Order not found');
    }

    const updated = await prisma.$transaction(async (tx) => {
      const result = await tx.order.update({
        where: { id: orderId },
        data: { status: newStatus },
      });

      // When order status is set to COMPLETED, award loyalty points (1 point per ₹10 spent)
      if (newStatus === 'COMPLETED') {
        const earnedPoints = Math.floor(order.totalAmount / 10);
        if (earnedPoints > 0) {
          const loyaltyAccount = await tx.loyaltyAccount.findUnique({
            where: { userId: order.userId },
          });

          if (loyaltyAccount) {
            const updatedAccount = await tx.loyaltyAccount.update({
              where: { id: loyaltyAccount.id },
              data: {
                pointsBalance: { increment: earnedPoints },
                lifetimePoints: { increment: earnedPoints },
              },
            });

            await tx.loyaltyTransaction.create({
              data: {
                loyaltyAccountId: loyaltyAccount.id,
                type: 'EARN',
                points: earnedPoints,
                description: `Earned points for Order #${order.orderNumber}`,
                referenceId: order.id,
              },
            });

            // Re-calculate tier based on lifetime points
            let newTier = 'BRONZE';
            if (updatedAccount.lifetimePoints >= 2000) newTier = 'VIP';
            else if (updatedAccount.lifetimePoints >= 1000) newTier = 'GOLD';
            else if (updatedAccount.lifetimePoints >= 500) newTier = 'SILVER';

            if (newTier !== updatedAccount.tier) {
              await tx.loyaltyAccount.update({
                where: { id: loyaltyAccount.id },
                data: { tier: newTier },
              });
            }
          }
        }
      }

      return result;
    });

    return updated;
  }
}

module.exports = OrdersService;
