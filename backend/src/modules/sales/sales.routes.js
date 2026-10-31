const express = require('express');
const DailySalesController = require('./daily_sales.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

router.use(authenticate);

// Staff Daily Sales Entry & My Records
router.post('/daily', authorize('STAFF', 'ADMIN'), DailySalesController.recordDailySales);
router.get('/daily/my-records', authorize('STAFF', 'ADMIN'), DailySalesController.getMyDailySales);

module.exports = router;
