const express = require('express');
const RecommendationsController = require('./recommendations.controller');

const router = express.Router();

router.get('/', RecommendationsController.getRecommendations);
router.get('/combos', RecommendationsController.getCombos);

module.exports = router;
