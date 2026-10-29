const express = require('express');
const StaffController = require('./staff.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

router.use(authenticate);
router.use(authorize('OWNER'));

router.get('/', StaffController.getStaffList);
router.post('/', StaffController.createStaffAccount);
router.patch('/:id/role', StaffController.updateStaffRole);

module.exports = router;
