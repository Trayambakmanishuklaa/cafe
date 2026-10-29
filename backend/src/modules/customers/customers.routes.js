const express = require('express');
const CustomersController = require('./customers.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

router.use(authenticate);
router.use(authorize('OWNER'));

router.get('/', CustomersController.getCustomerList);
router.get('/:id', CustomersController.getCustomerDetails);
router.post('/:id/adjust-points', CustomersController.adjustPoints);

module.exports = router;
