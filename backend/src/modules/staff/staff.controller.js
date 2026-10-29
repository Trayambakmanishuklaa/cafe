const StaffService = require('./staff.service');

class StaffController {
  static async getStaffList(req, res, next) {
    try {
      const staffList = await StaffService.getStaffList();
      res.status(200).json({
        success: true,
        data: staffList,
      });
    } catch (error) {
      next(error);
    }
  }

  static async createStaffAccount(req, res, next) {
    try {
      const staff = await StaffService.createStaffAccount(req.body);
      res.status(201).json({
        success: true,
        message: 'Staff account created successfully',
        data: staff,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateStaffRole(req, res, next) {
    try {
      const updated = await StaffService.updateStaffRole(req.params.id, req.body.role);
      res.status(200).json({
        success: true,
        message: 'Staff role updated',
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = StaffController;
