const { z } = require('zod');

const createOrderSchema = z.object({
  body: z.object({
    orderType: z.enum(['DINE_IN', 'TAKEAWAY', 'PRE_ORDER']),
    tableId: z.string().optional(),
    bookingId: z.string().optional(),
    couponCode: z.string().optional(),
    items: z.array(
      z.object({
        productId: z.string(),
        quantity: z.number().int().min(1),
        customizations: z.array(z.string()).optional(),
      })
    ).min(1, 'Order must contain at least one item'),
  }),
});

const updateOrderStatusSchema = z.object({
  body: z.object({
    status: z.enum(['ACCEPTED', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED']),
  }),
});

module.exports = {
  createOrderSchema,
  updateOrderStatusSchema,
};
