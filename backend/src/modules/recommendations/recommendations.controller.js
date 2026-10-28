const RecommendationsService = require('./recommendations.service');

class RecommendationsController {
  static async getRecommendations(req, res, next) {
    try {
      const recs = await RecommendationsService.getRecommendations(req.query);
      res.status(200).json({
        success: true,
        data: recs,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getCombos(req, res, next) {
    try {
      const combos = await RecommendationsService.getCombos();
      res.status(200).json({
        success: true,
        data: combos,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = RecommendationsController;
