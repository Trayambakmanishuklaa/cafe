const BookingsService = require('./bookings.service');

class BookingsController {
  static async getTables(req, res, next) {
    try {
      const tables = await BookingsService.getTables();
      res.status(200).json({
        success: true,
        data: tables,
      });
    } catch (error) {
      next(error);
    }
  }

  static async checkAvailability(req, res, next) {
    try {
      const tables = await BookingsService.checkAvailability(req.query);
      res.status(200).json({
        success: true,
        data: tables,
      });
    } catch (error) {
      next(error);
    }
  }

  static async createHold(req, res, next) {
    try {
      const hold = await BookingsService.createHold(req.user.id, req.body);
      res.status(201).json({
        success: true,
        message: 'Table held for 5 minutes',
        data: hold,
      });
    } catch (error) {
      next(error);
    }
  }

  static async createBooking(req, res, next) {
    try {
      const booking = await BookingsService.confirmBookingWithPayment(req.user.id, req.body);
      res.status(201).json({
        success: true,
        message: 'Seat deposit paid and reservation confirmed!',
        data: booking,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getMyBookings(req, res, next) {
    try {
      const bookings = await BookingsService.getMyBookings(req.user.id);
      res.status(200).json({
        success: true,
        data: bookings,
      });
    } catch (error) {
      next(error);
    }
  }

  static async checkInBooking(req, res, next) {
    try {
      const result = await BookingsService.checkInBooking(req.params.bookingCode);
      res.status(200).json({
        success: true,
        message: 'Guest successfully checked in!',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = BookingsController;
