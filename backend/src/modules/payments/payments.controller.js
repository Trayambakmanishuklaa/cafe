const PaymentsService = require('./payments.service');

class PaymentsController {
  static async createPaymentIntent(req, res, next) {
    try {
      const intent = await PaymentsService.createPaymentIntent(req.user.id, req.body);
      res.status(201).json({
        success: true,
        data: intent,
      });
    } catch (error) {
      next(error);
    }
  }

  static async verifyPayment(req, res, next) {
    try {
      const result = await PaymentsService.verifyPayment(req.user.id, req.body);
      res.status(200).json({
        success: true,
        message: 'Payment verified successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  static async handleWebhook(req, res, next) {
    try {
      const signature = req.headers['x-razorpay-signature'];
      await PaymentsService.processWebhook(signature, req.body);
      res.status(200).json({ status: 'ok' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = PaymentsController;
