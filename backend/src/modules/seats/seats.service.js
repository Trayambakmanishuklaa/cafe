const prisma = require('../../database/prisma');
const { ApiError } = require('../../middleware/errorHandler');

class SeatsService {
  static async getSeats() {
    return await prisma.cafeTable.findMany({
      where: { isActive: true },
      orderBy: { tableNumber: 'asc' },
    });
  }

  static async createSeat({ tableNumber, name, capacity, description, manualStatus, staffId }) {
    const existing = await prisma.cafeTable.findUnique({
      where: { tableNumber: parseInt(tableNumber, 10) },
    });

    if (existing) {
      throw new ApiError(400, `Seat/Table number #${tableNumber} already exists`);
    }

    return await prisma.cafeTable.create({
      data: {
        tableNumber: parseInt(tableNumber, 10),
        name: name || `Table ${tableNumber}`,
        capacity: capacity ? parseInt(capacity, 10) : 4,
        description: description || null,
        manualStatus: manualStatus || 'FREE',
        createdByStaffId: staffId,
        qrCode: `TABLE_${tableNumber}_QR_CODE`,
      },
    });
  }

  static async updateSeat(id, { name, capacity, description, isActive }) {
    const seat = await prisma.cafeTable.findUnique({ where: { id } });
    if (!seat) {
      throw new ApiError(404, 'Seat not found');
    }

    const data = {};
    if (name) data.name = name;
    if (capacity) data.capacity = parseInt(capacity, 10);
    if (description !== undefined) data.description = description;
    if (isActive !== undefined) data.isActive = isActive;

    return await prisma.cafeTable.update({
      where: { id },
      data,
    });
  }

  static async updateSeatStatus(id, manualStatus) {
    const seat = await prisma.cafeTable.findUnique({
      where: { id },
      include: {
        bookings: {
          where: { status: { in: ['CONFIRMED', 'CHECKED_IN'] } },
        },
      },
    });

    if (!seat) {
      throw new ApiError(404, 'Seat not found');
    }

    // Guard: Cannot mark as FREE if there is a confirmed customer booking
    if (manualStatus === 'FREE' && seat.bookings.length > 0) {
      throw new ApiError(400, 'Cannot mark seat as Free because there is an active confirmed customer booking on this table.');
    }

    return await prisma.cafeTable.update({
      where: { id },
      data: { manualStatus },
    });
  }

  static async getAvailability({ date, startTime, endTime, guestCount }) {
    const parsedDate = new Date(date);
    const guests = guestCount ? parseInt(guestCount, 10) : 1;

    // Fetch active seats matching capacity
    const seats = await prisma.cafeTable.findMany({
      where: {
        isActive: true,
        capacity: { gte: guests },
      },
      orderBy: { tableNumber: 'asc' },
    });

    // Check confirmed customer bookings for that date
    const bookings = await prisma.booking.findMany({
      where: {
        bookingDate: parsedDate,
        status: { in: ['CONFIRMED', 'CHECKED_IN'] },
      },
    });

    // Check active temporary holds
    const holds = await prisma.bookingHold.findMany({
      where: {
        bookingDate: parsedDate,
        expiresAt: { gt: new Date() },
      },
    });

    const bookedTableIds = new Set(bookings.map((b) => b.tableId));
    const heldTableIds = new Set(holds.map((h) => h.tableId));

    return seats.map((seat) => {
      let effectiveStatus = seat.manualStatus; // FREE, BOOKED, MAINTENANCE
      if (bookedTableIds.has(seat.id)) {
        effectiveStatus = 'BOOKED';
      } else if (heldTableIds.has(seat.id)) {
        effectiveStatus = 'RESERVED';
      }

      return {
        ...seat,
        effectiveStatus,
        isAvailable: seat.manualStatus == 'FREE' && !bookedTableIds.has(seat.id) && !heldTableIds.has(seat.id),
      };
    });
  }
}

module.exports = SeatsService;
