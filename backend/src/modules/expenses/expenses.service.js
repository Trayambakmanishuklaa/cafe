const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class ExpensesService {
  static async createExpense({ category, itemDetails, amount, expenseDate, paymentMethod, note, createdBy }) {
    if (!category || !itemDetails || !amount) {
      throw new ApiError(400, 'Category, item details, and amount are required');
    }

    const numericAmount = parseFloat(amount);
    if (isNaN(numericAmount) || numericAmount <= 0) {
      throw new ApiError(400, 'Amount must be greater than zero');
    }

    const dateVal = expenseDate ? new Date(expenseDate) : new Date();

    return await prisma.expense.create({
      data: {
        category,
        itemDetails,
        amount: numericAmount,
        expenseDate: dateVal,
        paymentMethod: paymentMethod || 'Cash',
        note: note || null,
        createdBy,
      },
    });
  }

  static async getMonthlyExpenses(month, year) {
    const targetYear = year ? parseInt(year, 10) : new Date().getFullYear();
    const targetMonth = month ? parseInt(month, 10) - 1 : new Date().getMonth();

    // Asia/Kolkata timezone friendly start and end of month
    const startDate = new Date(targetYear, targetMonth, 1, 0, 0, 0);
    const endDate = new Date(targetYear, targetMonth + 1, 0, 23, 59, 59);

    const expenses = await prisma.expense.findMany({
      where: {
        expenseDate: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: { expenseDate: 'asc' },
    });

    const totalDaysInMonth = new Date(targetYear, targetMonth + 1, 0).getDate();

    // Map daily totals
    const dailyMap = {};
    for (let d = 1; d <= totalDaysInMonth; d++) {
      dailyMap[d] = 0.0;
    }

    let totalExpense = 0.0;

    for (const exp of expenses) {
      const expDay = new Date(exp.expenseDate).getDate();
      if (dailyMap[expDay] !== undefined) {
        dailyMap[expDay] += exp.amount;
      }
      totalExpense += exp.amount;
    }

    const dailyExpenses = Object.keys(dailyMap).map((d) => ({
      day: parseInt(d, 10),
      total: dailyMap[d],
    }));

    return {
      month: targetMonth + 1,
      year: targetYear,
      totalExpense,
      dailyExpenses,
      recordsCount: expenses.length,
    };
  }

  static async getExpenses({ category, startDate, endDate }) {
    const where = {};
    if (category) where.category = category;
    if (startDate && endDate) {
      where.expenseDate = {
        gte: new Date(startDate),
        lte: new Date(endDate),
      };
    }

    return await prisma.expense.findMany({
      where,
      include: {
        user: { select: { id: true, name: true, email: true } },
      },
      orderBy: { expenseDate: 'desc' },
    });
  }
}

module.exports = ExpensesService;
