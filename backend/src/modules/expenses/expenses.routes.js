const express = require('express');
const ExpensesController = require('./expenses.controller');
const authenticate = require('../../middleware/authenticate');
const authorize = require('../../middleware/authorize');

const router = express.Router();

router.use(authenticate, authorize('STAFF', 'ADMIN'));

router.post('/', ExpensesController.createExpense);
router.get('/monthly', ExpensesController.getMonthlyExpenses);
router.get('/', ExpensesController.getExpenses);

module.exports = router;
