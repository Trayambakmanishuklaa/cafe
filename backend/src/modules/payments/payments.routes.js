const express = require('express');
const PaymentsController = require('./payments.controller');
const authenticate = require('../../middleware/authenticate');

const router = express.Router();

router.post('/webhook', PaymentsController.handleWebhook);

router.use(authenticate);
router.post('/create', PaymentsController.createPaymentIntent);
router.post('/verify', PaymentsController.verifyPayment);

module.exports = router;
