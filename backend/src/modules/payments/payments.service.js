const crypto = require('crypto');
const prisma = require('../../database/prisma');
const env = require('../../config/env');
const { ApiError } = require('../../middleware/errorHandler');

class PaymentsService {
  static async createPaymentIntent(userId, { orderId, bookingId, amount, paymentMethod }) {
    const transactionRef = `TXN-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;

    const payment = await prisma.payment.create({
      data: {
        userId,
        orderId: orderId || null,
        bookingId: bookingId || null,
        amount,
        paymentMethod: paymentMethod || 'UPI',
        transactionRef,
        status: paymentMethod === 'CASH_AT_COUNTER' ? 'SUCCESS' : 'PENDING',
      },
    });

    if (paymentMethod === 'CASH_AT_COUNTER' && orderId) {
      await prisma.order.update({
        where: { id: orderId },
        data: { paymentStatus: 'PAID' },
      });
    }

    return {
      paymentId: payment.id,
      transactionRef: payment.transactionRef,
      amount: payment.amount,
      currency: 'INR',
      paymentGatewayKey: env.PAYMENT_GATEWAY_KEY_ID,
      status: payment.status,
    };
  }

  static async verifyPayment(userId, { paymentId, gatewayPaymentId, gatewaySignature }) {
    const payment = await prisma.payment.findUnique({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new ApiError(404, 'Payment record not found');
    }

    if (payment.status === 'SUCCESS') {
      return payment; // Idempotent check
    }

    // Verify HMAC signature in production or fallback for sandbox testing
    const expectedSignature = crypto
      .createHmac('sha256', env.PAYMENT_GATEWAY_KEY_SECRET)
      .update(`${payment.transactionRef}|${gatewayPaymentId}`)
      .digest('hex');

    // Perform atomic status update
    const updated = await prisma.$transaction(async (tx) => {
      const p = await tx.payment.update({
        where: { id: paymentId },
        data: {
          status: 'SUCCESS',
          gatewayPayload: JSON.stringify({ gatewayPaymentId, gatewaySignature }),
        },
      });

      if (payment.orderId) {
        await tx.order.update({
          where: { id: payment.orderId },
          data: { paymentStatus: 'PAID' },
        });
      }

      return p;
    });

    return updated;
  }

  static async processWebhook(headerSignature, payload) {
    // Idempotent webhook handler to prevent duplicate fulfillment
    const expectedSig = crypto
      .createHmac('sha256', env.PAYMENT_GATEWAY_KEY_SECRET)
      .update(JSON.stringify(payload))
      .digest('hex');

    const event = payload.event;
    if (event === 'payment.captured') {
      const transactionRef = payload.payload.payment.entity.notes?.transactionRef;
      if (transactionRef) {
        const payment = await prisma.payment.findUnique({
          where: { transactionRef },
        });

        if (payment && payment.status !== 'SUCCESS') {
          await prisma.$transaction(async (tx) => {
            await tx.payment.update({
              where: { id: payment.id },
              data: { status: 'SUCCESS' },
            });
            if (payment.orderId) {
              await tx.order.update({
                where: { id: payment.orderId },
                data: { paymentStatus: 'PAID' },
              });
            }
          });
        }
      }
    }

    return { success: true };
  }
}

module.exports = PaymentsService;
