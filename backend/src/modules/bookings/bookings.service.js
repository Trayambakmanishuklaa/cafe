const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class BookingsService {
  static async getTables() {
    return await prisma.cafeTable.findMany({
      orderBy: { tableNumber: 'asc' },
    });
  }

  static async checkAvailability({ date, startTime, guestCount }) {
    const parsedDate = new Date(date);
    const guests = guestCount ? parseInt(guestCount, 10) : 1;

    // Fetch all tables matching capacity
    const eligibleTables = await prisma.cafeTable.findMany({
      where: {
        capacity: { gte: guests },
        status: { not: 'MAINTENANCE' },
      },
      orderBy: { tableNumber: 'asc' },
    });

    // Check existing confirmed bookings for that date
    const existingBookings = await prisma.booking.findMany({
      where: {
        bookingDate: parsedDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
      },
    });

    const bookedTableIds = new Set(existingBookings.map((b) => b.tableId));

    // Also check non-expired holds
    const activeHolds = await prisma.bookingHold.findMany({
      where: {
        bookingDate: parsedDate,
        expiresAt: { gt: new Date() },
      },
    });
    const heldTableIds = new Set(activeHolds.map((h) => h.tableId));

    return eligibleTables.map((table) => ({
      ...table,
      isAvailable: !bookedTableIds.has(table.id) && !heldTableIds.has(table.id),
      isHeld: heldTableIds.has(table.id),
    }));
  }

  static async createHold(userId, { tableId, bookingDate, startTime, endTime }) {
    const parsedDate = new Date(bookingDate);

    return await prisma.$transaction(async (tx) => {
      // 1. Check existing booking overlap
      const overlapBooking = await tx.booking.findFirst({
        where: {
          tableId,
          bookingDate: parsedDate,
          status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        },
      });

      if (overlapBooking) {
        throw new ApiError(409, 'This table is already reserved for the selected time slot.');
      }

      // 2. Check active hold overlap from another user
      const overlapHold = await tx.bookingHold.findFirst({
        where: {
          tableId,
          bookingDate: parsedDate,
          expiresAt: { gt: new Date() },
          userId: { not: userId },
        },
      });

      if (overlapHold) {
        throw new ApiError(409, 'This table is temporarily held by another customer.');
      }

      // 3. Create or refresh 5-minute temporary hold
      await tx.bookingHold.deleteMany({ where: { tableId, userId } });

      const expiresAt = new Date(Date.now() + 5 * 60 * 1000);
      return await tx.bookingHold.create({
        data: {
          tableId,
          userId,
          bookingDate: parsedDate,
          startTime,
          endTime,
          expiresAt,
        },
      });
    });
  }

  static async confirmBookingWithPayment(userId, { tableId, guestCount, bookingDate, startTime, endTime, paymentMethod }) {
    const parsedDate = new Date(bookingDate);
    const bookingCode = `SEAT-${Math.floor(100000 + Math.random() * 900000)}`;
    const qrCode = `CAFE_BOOKING_${bookingCode}`;
    const bookingFee = 50.0; // ₹50 advance seat deposit

    return await prisma.$transaction(async (tx) => {
      // Re-validate availability
      const existingBooking = await tx.booking.findFirst({
        where: {
          tableId,
          bookingDate: parsedDate,
          status: { in: ['CONFIRMED', 'CHECKED_IN'] },
        },
      });

      if (existingBooking) {
        throw new ApiError(409, 'Double Booking Prevented: Table is already confirmed for another user.');
      }

      // Create Payment record for advance deposit
      const transactionRef = `DEP-${Date.now()}-${Math.floor(1000 + Math.random() * 9000)}`;

      const payment = await tx.payment.create({
        data: {
          userId,
          amount: bookingFee,
          paymentMethod: paymentMethod || 'UPI',
          transactionRef,
          status: 'SUCCESS', // Confirmed payment
        },
      });

      // Create Confirmed Booking record
      const booking = await tx.booking.create({
        data: {
          bookingCode,
          userId,
          tableId,
          guestCount,
          bookingDate: parsedDate,
          startTime,
          endTime,
          status: 'CONFIRMED',
          bookingFee,
          depositAmount: bookingFee,
          qrCode,
        },
        include: {
          table: true,
          user: { select: { name: true, phone: true } },
        },
      });

      // Link payment to booking
      await tx.payment.update({
        where: { id: payment.id },
        data: { bookingId: booking.id },
      });

      // Clear hold
      await tx.bookingHold.deleteMany({
        where: { tableId, userId },
      });

      return booking;
    });
  }

  static async getMyBookings(userId) {
    return await prisma.booking.findMany({
      where: { userId },
      include: {
        table: true,
      },
      orderBy: { bookingDate: 'desc' },
    });
  }

  static async checkInBooking(bookingCode) {
    const booking = await prisma.booking.findUnique({
      where: { bookingCode },
      include: { table: true },
    });

    if (!booking) {
      throw new ApiError(404, 'Booking pass not found');
    }

    if (booking.status === 'CHECKED_IN') {
      throw new ApiError(400, 'Customer has already checked in');
    }

    return await prisma.$transaction(async (tx) => {
      const updated = await tx.booking.update({
        where: { id: booking.id },
        data: { status: 'CHECKED_IN' },
      });

      await tx.cafeTable.update({
        where: { id: booking.tableId },
        data: { status: 'OCCUPIED' },
      });

      return updated;
    });
  }
}

module.exports = BookingsService;
