const express = require('express');
const AdminController = require('./admin.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

router.use(authenticate);
router.use(authorize('OWNER'));

router.get('/overview', AdminController.getOverview);
router.patch('/products/:id/availability', AdminController.toggleProduct);
router.post('/products', AdminController.createProduct);

module.exports = router;
