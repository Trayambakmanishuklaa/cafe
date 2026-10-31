const prisma = require('../../database/prisma');

class DashboardOverviewService {
  static async getCombinedOverview() {
    // 1. Total Daily Sales
    const salesList = await prisma.dailySales.findMany();
    let totalSales = 0.0;
    for (const s of salesList) {
      totalSales += s.totalSales;
    }

    // 2. Total Expenses
    const expensesList = await prisma.expense.findMany();
    let totalExpenses = 0.0;
    for (const e of expensesList) {
      totalExpenses += e.amount;
    }

    // 3. Net Operating Difference
    const netOperatingDifference = totalSales - totalExpenses;

    // 4. Total Orders Count
    const totalOrders = await prisma.order.count();

    // 5. Total Staff Count
    const totalStaff = await prisma.user.count({ where: { role: 'STAFF' } });

    return {
      totalSales,
      totalExpenses,
      netOperatingDifference,
      totalOrders,
      totalStaff,
      salesCount: salesList.length,
      expenseCount: expensesList.length,
    };
  }
}

module.exports = DashboardOverviewService;
