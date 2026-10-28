const express = require('express');
const ProductsController = require('./products.controller');

const router = express.Router();

router.get('/', ProductsController.getAll);
router.get('/combos', ProductsController.getCombos);
router.get('/:id', ProductsController.getById);

module.exports = router;
