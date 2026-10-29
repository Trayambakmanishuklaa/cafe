const express = require('express');
const SeatsController = require('./seats.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

// Public / Customer Seat Browsing & Availability
router.get('/', SeatsController.getSeats);
router.get('/availability', SeatsController.getAvailability);

// Staff Seat Management (Supports both /seats and /seats/staff variations)
router.post('/', authenticate, authorize('STAFF'), SeatsController.createSeat);
router.post('/staff', authenticate, authorize('STAFF'), SeatsController.createSeat);

router.patch('/:id', authenticate, authorize('STAFF'), SeatsController.updateSeat);
router.patch('/staff/:id', authenticate, authorize('STAFF'), SeatsController.updateSeat);

router.patch('/:id/status', authenticate, authorize('STAFF'), SeatsController.updateSeatStatus);
router.patch('/staff/:id/status', authenticate, authorize('STAFF'), SeatsController.updateSeatStatus);

module.exports = router;
