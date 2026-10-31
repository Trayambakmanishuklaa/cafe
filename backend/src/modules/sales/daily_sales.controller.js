const DailySalesService = require('./daily_sales.service');

class DailySalesController {
  static async recordDailySales(req, res, next) {
    try {
      const record = await DailySalesService.recordDailySales({
        ...req.body,
        staffId: req.user.id,
      });
      res.status(201).json({
        success: true,
        message: 'Daily sales record saved successfully',
        data: record,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getMyDailySales(req, res, next) {
    try {
      const records = await DailySalesService.getMyDailySales(req.user.id);
      res.status(200).json({
        success: true,
        data: records,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAdminSalesByDate(req, res, next) {
    try {
      const data = await DailySalesService.getAdminSalesByDate(req.query.date);
      res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAdminMonthlySales(req, res, next) {
    try {
      const data = await DailySalesService.getAdminMonthlySales(req.query.month, req.query.year);
      res.status(200).json({
        success: true,
        data,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = DailySalesController;
