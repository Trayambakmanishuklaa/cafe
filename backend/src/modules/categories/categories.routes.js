const express = require('express');
const CategoriesController = require('./categories.controller');

const router = express.Router();

router.get('/', CategoriesController.getAll);

module.exports = router;
