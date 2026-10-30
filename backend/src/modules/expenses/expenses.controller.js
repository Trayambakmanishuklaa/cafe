const ExpensesService = require('./expenses.service');

class ExpensesController {
  static async createExpense(req, res, next) {
    try {
      const expense = await ExpensesService.createExpense({
        ...req.body,
        createdBy: req.user.id,
      });
      res.status(201).json({
        success: true,
        message: 'Expense recorded successfully',
        data: expense,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getMonthlyExpenses(req, res, next) {
    try {
      const data = await ExpensesService.getMonthlyExpenses(req.query.month, req.query.year);
      res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getExpensesByDate(req, res, next) {
    try {
      const data = await ExpensesService.getExpensesByDate(req.query.date);
      res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getExpenses(req, res, next) {
    try {
      const expenses = await ExpensesService.getExpenses(req.query);
      res.status(200).json({
        success: true,
        data: expenses,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = ExpensesController;
