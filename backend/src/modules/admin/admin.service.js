const prisma = require('../../database/prisma');

class AdminService {
  static async getBusinessOverview() {
    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    // Today's total sales & completed orders count
    const todayOrders = await prisma.order.findMany({
      where: {
        createdAt: { gte: todayStart },
        status: { not: 'CANCELLED' },
      },
    });

    const todaySales = todayOrders.reduce((sum, o) => sum + o.totalAmount, 0);
    const completedOrdersCount = todayOrders.filter((o) => o.status === 'COMPLETED').length;
    const avgOrderValue = todayOrders.length > 0 ? todaySales / todayOrders.length : 0;

    // Seating occupancy
    const totalTables = await prisma.cafeTable.count();
    const occupiedTables = await prisma.cafeTable.count({
      where: { status: 'OCCUPIED' },
    });
    const seatUtilization = totalTables > 0 ? (occupiedTables / totalTables) * 100 : 0;

    // Category Revenue Split
    const categoryRevenueMap = {
      'tea': 0,
      'coffee': 0,
      'bun-bakery': 0,
      'burger': 0,
    };

    const orderItems = await prisma.orderItem.findMany({
      include: {
        product: {
          include: { category: true },
        },
      },
    });

    for (const item of orderItems) {
      const slug = item.product?.category?.slug;
      if (slug && categoryRevenueMap[slug] !== undefined) {
        categoryRevenueMap[slug] += item.subtotal;
      }
    }

    return {
      todaySales: Math.round(todaySales * 100) / 100,
      totalOrdersCount: todayOrders.length,
      completedOrdersCount,
      avgOrderValue: Math.round(avgOrderValue * 100) / 100,
      seatUtilization: Math.round(seatUtilization),
      totalTables,
      occupiedTables,
      categoryRevenueMap,
    };
  }

  static async toggleProductAvailability(productId, isAvailable) {
    return await prisma.product.update({
      where: { id: productId },
      data: { isAvailable },
    });
  }

  static async createProduct(data) {
    return await prisma.product.create({ data });
  }
}

module.exports = AdminService;
