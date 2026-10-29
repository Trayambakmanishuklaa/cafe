const SeatsService = require('./seats.service');

class SeatsController {
  static async getSeats(req, res, next) {
    try {
      const seats = await SeatsService.getSeats();
      res.status(200).json({ success: true, data: seats });
    } catch (error) {
      next(error);
    }
  }

  static async createSeat(req, res, next) {
    try {
      const seat = await SeatsService.createSeat({
        ...req.body,
        staffId: req.user.id,
      });
      res.status(201).json({ success: true, message: 'Seat added successfully', data: seat });
    } catch (error) {
      next(error);
    }
  }

  static async updateSeat(req, res, next) {
    try {
      const updated = await SeatsService.updateSeat(req.params.id, req.body);
      res.status(200).json({ success: true, message: 'Seat updated successfully', data: updated });
    } catch (error) {
      next(error);
    }
  }

  static async updateSeatStatus(req, res, next) {
    try {
      const updated = await SeatsService.updateSeatStatus(req.params.id, req.body.manualStatus);
      res.status(200).json({ success: true, message: 'Seat status updated', data: updated });
    } catch (error) {
      next(error);
    }
  }

  static async getAvailability(req, res, next) {
    try {
      const availability = await SeatsService.getAvailability(req.query);
      res.status(200).json({ success: true, data: availability });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = SeatsController;
