const OrdersService = require('./orders.service');

class OrdersController {
  static async createOrder(req, res, next) {
    try {
      const order = await OrdersService.createOrder(req.user.id, req.body);
      res.status(201).json({
        success: true,
        message: 'Order created successfully',
        data: order,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getMyOrders(req, res, next) {
    try {
      const orders = await OrdersService.getMyOrders(req.user.id);
      res.status(200).json({
        success: true,
        data: orders,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getOrderById(req, res, next) {
    try {
      const order = await OrdersService.getOrderById(
        req.params.id,
        req.user.id,
        req.user.role
      );
      res.status(200).json({
        success: true,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAllStaffOrders(req, res, next) {
    try {
      const orders = await OrdersService.getAllStaffOrders(req.query);
      res.status(200).json({
        success: true,
        data: orders,
      });
    } catch (error) {
      next(error);
    }
  }

  static async updateOrderStatus(req, res, next) {
    try {
      const order = await OrdersService.updateOrderStatus(
        req.params.id,
        req.body.status,
        req.user.id
      );
      res.status(200).json({
        success: true,
        message: `Order status updated to ${req.body.status}`,
        data: order,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = OrdersController;
