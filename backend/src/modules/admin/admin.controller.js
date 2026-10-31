const StaffManagementService = require('./staff_management.service');
const DailySalesService = require('../sales/daily_sales.service');
const DashboardOverviewService = require('./dashboard_overview.service');

class AdminController {
  static async createStaff(req, res, next) {
    try {
      const staff = await StaffManagementService.createStaff(req.body);
      res.status(201).json({ success: true, message: 'Staff account created successfully', data: staff });
    } catch (error) {
      next(error);
    }
  }

  static async getStaffList(req, res, next) {
    try {
      const staff = await StaffManagementService.getStaffList(req.query.search);
      res.status(200).json({ success: true, data: staff });
    } catch (error) {
      next(error);
    }
  }

  static async resetStaffPassword(req, res, next) {
    try {
      const updated = await StaffManagementService.resetStaffPassword(req.params.id, req.body.newPassword);
      res.status(200).json({ success: true, message: 'Staff password reset successfully', data: updated });
    } catch (error) {
      next(error);
    }
  }

  static async getAdminSalesByDate(req, res, next) {
    try {
      const data = await DailySalesService.getAdminSalesByDate(req.query.date);
      res.status(200).json({ success: true, data });
    } catch (error) {
      next(error);
    }
  }

  static async getAdminMonthlySales(req, res, next) {
    try {
      const data = await DailySalesService.getAdminMonthlySales(req.query.month, req.query.year);
      res.status(200).json({ success: true, data });
    } catch (error) {
      next(error);
    }
  }

  static async getCombinedOverview(req, res, next) {
    try {
      const data = await DashboardOverviewService.getCombinedOverview();
      res.status(200).json({ success: true, data });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AdminController;
