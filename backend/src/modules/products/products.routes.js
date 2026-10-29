const express = require('express');
const ProductsController = require('./products.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

// Public / Customer Product Browsing
router.get('/', ProductsController.getAll);
router.get('/combos', ProductsController.getCombos);

// Staff Product Management
router.get('/staff/all', authenticate, authorize('STAFF'), ProductsController.getAllForStaff);
router.post('/', authenticate, authorize('STAFF'), ProductsController.createProduct);
router.patch('/:id', authenticate, authorize('STAFF'), ProductsController.updateProduct);
router.patch('/:id/availability', authenticate, authorize('STAFF'), ProductsController.toggleAvailability);

router.get('/:id', ProductsController.getById);

module.exports = router;
