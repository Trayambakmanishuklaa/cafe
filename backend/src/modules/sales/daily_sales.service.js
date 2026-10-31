const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class DailySalesService {
  static async recordDailySales({ salesDate, totalSales, note, staffId }) {
    if (totalSales === undefined || totalSales === null) {
      throw new ApiError(400, 'Total sales amount is required');
    }

    const numericSales = parseFloat(totalSales);
    if (isNaN(numericSales) || numericSales < 0) {
      throw new ApiError(400, 'Total sales amount must be greater than or equal to zero');
    }

    const dateVal = salesDate ? new Date(salesDate) : new Date();
    dateVal.setHours(0, 0, 0, 0); // Normalize to start of day

    return await prisma.dailySales.upsert({
      where: {
        staffId_salesDate: {
          staffId,
          salesDate: dateVal,
        },
      },
      update: {
        totalSales: numericSales,
        note: note || null,
      },
      create: {
        staffId,
        salesDate: dateVal,
        totalSales: numericSales,
        note: note || null,
      },
    });
  }

  static async getMyDailySales(staffId) {
    return await prisma.dailySales.findMany({
      where: { staffId },
      orderBy: { salesDate: 'desc' },
    });
  }

  static async getAdminSalesByDate(dateStr) {
    const targetDate = dateStr ? new Date(dateStr) : new Date();
    targetDate.setHours(0, 0, 0, 0);

    const nextDate = new Date(targetDate);
    nextDate.setDate(nextDate.getDate() + 1);

    const records = await prisma.dailySales.findMany({
      where: {
        salesDate: {
          gte: targetDate,
          lt: nextDate,
        },
      },
      include: {
        staff: { select: { id: true, name: true, phone: true, email: true } },
      },
      orderBy: { createdAt: 'desc' },
    });

    let totalCombinedSales = 0.0;
    for (const r of records) {
      totalCombinedSales += r.totalSales;
    }

    return {
      date: targetDate.toISOString().split('T')[0],
      totalCombinedSales,
      records,
    };
  }

  static async getAdminMonthlySales(month, year) {
    const targetYear = year ? parseInt(year, 10) : new Date().getFullYear();
    const targetMonth = month ? parseInt(month, 10) - 1 : new Date().getMonth();

    const startDate = new Date(targetYear, targetMonth, 1, 0, 0, 0);
    const endDate = new Date(targetYear, targetMonth + 1, 0, 23, 59, 59);

    const sales = await prisma.dailySales.findMany({
      where: {
        salesDate: {
          gte: startDate,
          lte: endDate,
        },
      },
      include: { staff: { select: { name: true } } },
      orderBy: { salesDate: 'asc' },
    });

    const totalDaysInMonth = new Date(targetYear, targetMonth + 1, 0).getDate();
    const dailyMap = {};
    for (let d = 1; d <= totalDaysInMonth; d++) {
      dailyMap[d] = 0.0;
    }

    let monthlyTotalSales = 0.0;

    for (const s of sales) {
      const dayNum = new Date(s.salesDate).getDate();
      if (dailyMap[dayNum] !== undefined) {
        dailyMap[dayNum] += s.totalSales;
      }
      monthlyTotalSales += s.totalSales;
    }

    const dailySalesGraph = Object.keys(dailyMap).map((d) => ({
      day: parseInt(d, 10),
      total: dailyMap[d],
    }));

    return {
      month: targetMonth + 1,
      year: targetYear,
      monthlyTotalSales,
      dailySalesGraph,
      recordsCount: sales.length,
    };
  }
}

module.exports = DailySalesService;
