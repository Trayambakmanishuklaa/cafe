const CustomersService = require('./customers.service');

class CustomersController {
  static async getCustomerList(req, res, next) {
    try {
      const customers = await CustomersService.getCustomerList(req.query);
      res.status(200).json({
        success: true,
        data: customers,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getCustomerDetails(req, res, next) {
    try {
      const customer = await CustomersService.getCustomerDetails(req.params.id);
      res.status(200).json({
        success: true,
        data: customer,
      });
    } catch (error) {
      next(error);
    }
  }

  static async adjustPoints(req, res, next) {
    try {
      const result = await CustomersService.adjustPoints(
        req.params.id,
        req.body,
        req.user.id
      );
      res.status(200).json({
        success: true,
        message: 'Loyalty points adjusted successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = CustomersController;
