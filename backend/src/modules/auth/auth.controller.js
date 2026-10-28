const AuthService = require('./auth.service');

class AuthController {
  static async register(req, res, next) {
    try {
      const result = await AuthService.register(req.body);
      res.status(201).json({
        success: true,
        message: 'Account registered successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  static async login(req, res, next) {
    try {
      const result = await AuthService.login(req.body);
      res.status(200).json({
        success: true,
        message: 'Login successful',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getProfile(req, res, next) {
    try {
      res.status(200).json({
        success: true,
        data: {
          user: req.user,
        },
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AuthController;
