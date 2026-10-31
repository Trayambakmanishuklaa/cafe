const express = require('express');
const AdminController = require('./admin.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

router.use(authenticate, authorize('ADMIN'));

// Staff Account Management
router.post('/staff', AdminController.createStaff);
router.get('/staff', AdminController.getStaffList);
router.patch('/staff/:id/reset-password', AdminController.resetStaffPassword);

// Daily Sales Reporting for Admin
router.get('/sales/by-date', AdminController.getAdminSalesByDate);
router.get('/sales/monthly', AdminController.getAdminMonthlySales);

// Combined Financial Overview
router.get('/dashboard/overview', AdminController.getCombinedOverview);

module.exports = router;
