const AdminService = require('./admin.service');

class AdminController {
  static async getOverview(req, res, next) {
    try {
      const overview = await AdminService.getBusinessOverview();
      res.status(200).json({
        success: true,
        data: overview,
      });
    } catch (error) {
      next(error);
    }
  }

  static async toggleProduct(req, res, next) {
    try {
      const updated = await AdminService.toggleProductAvailability(
        req.params.id,
        req.body.isAvailable
      );
      res.status(200).json({
        success: true,
        data: updated,
      });
    } catch (error) {
      next(error);
    }
  }

  static async createProduct(req, res, next) {
    try {
      const product = await AdminService.createProduct(req.body);
      res.status(201).json({
        success: true,
        data: product,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AdminController;
