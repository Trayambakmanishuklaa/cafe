const express = require('express');
const LoyaltyController = require('./loyalty.controller');
const authenticate = require('../../middleware/authenticate');

const router = express.Router();

router.use(authenticate);

router.get('/me', LoyaltyController.getPassport);
router.get('/rewards', LoyaltyController.getRewards);
router.post('/rewards/:id/redeem', LoyaltyController.redeemReward);

module.exports = router;
