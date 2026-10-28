const express = require('express');
const OrdersController = require('./orders.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');
const validate = require('../../middleware/validate');
const { createOrderSchema, updateOrderStatusSchema } = require('./orders.validation');

const router = express.Router();

router.use(authenticate);

// Customer endpoints
router.post('/', validate(createOrderSchema), OrdersController.createOrder);
router.get('/my', OrdersController.getMyOrders);

// Staff/Owner Queue endpoints
router.get('/staff/queue', authorize('STAFF', 'OWNER'), OrdersController.getAllStaffOrders);
router.patch('/:id/status', authorize('STAFF', 'OWNER'), validate(updateOrderStatusSchema), OrdersController.updateOrderStatus);

router.get('/:id', OrdersController.getOrderById);

module.exports = router;
