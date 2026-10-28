const express = require('express');
const BookingsController = require('./bookings.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');
const validate = require('../../middleware/validate');
const {
  availabilityQuerySchema,
  createHoldSchema,
  createBookingSchema,
} = require('./bookings.validation');

const router = express.Router();

router.use(authenticate);

router.get('/tables', BookingsController.getTables);
router.get('/availability', validate(availabilityQuerySchema), BookingsController.checkAvailability);
router.post('/hold', validate(createHoldSchema), BookingsController.createHold);
router.post('/', validate(createBookingSchema), BookingsController.createBooking);
router.get('/my', BookingsController.getMyBookings);

// Staff Check-In Pass Verification
router.post('/check-in/:bookingCode', authorize('STAFF', 'OWNER'), BookingsController.checkInBooking);

module.exports = router;
