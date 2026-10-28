const LoyaltyService = require('./loyalty.service');

class LoyaltyController {
  static async getPassport(req, res, next) {
    try {
      const passport = await LoyaltyService.getPassport(req.user.id);
      res.status(200).json({
        success: true,
        data: passport,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getRewards(req, res, next) {
    try {
      const rewards = await LoyaltyService.getRewards();
      res.status(200).json({
        success: true,
        data: rewards,
      });
    } catch (error) {
      next(error);
    }
  }

  static async redeemReward(req, res, next) {
    try {
      const result = await LoyaltyService.redeemReward(req.user.id, req.params.id);
      res.status(200).json({
        success: true,
        message: 'Reward redeemed successfully!',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = LoyaltyController;
