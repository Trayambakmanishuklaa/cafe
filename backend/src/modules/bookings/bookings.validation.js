const { z } = require('zod');

const availabilityQuerySchema = z.object({
  query: z.object({
    date: z.string(), // YYYY-MM-DD
    startTime: z.string(), // HH:mm
    guestCount: z.string().optional(),
  }),
});

const createHoldSchema = z.object({
  body: z.object({
    tableId: z.string(),
    bookingDate: z.string(),
    startTime: z.string(),
    endTime: z.string(),
  }),
});

const createBookingSchema = z.object({
  body: z.object({
    tableId: z.string(),
    guestCount: z.number().int().min(1),
    bookingDate: z.string(),
    startTime: z.string(),
    endTime: z.string(),
    preOrderId: z.string().optional(),
  }),
});

module.exports = {
  availabilityQuerySchema,
  createHoldSchema,
  createBookingSchema,
};
