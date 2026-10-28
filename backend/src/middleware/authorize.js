const { ApiError } = require('./errorHandler');

const authorize = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(new ApiError(401, 'User is not authenticated'));
    }

    if (!allowedRoles.includes(req.user.role)) {
      return next(
        new ApiError(403, `Access denied. Role '${req.user.role}' is not authorized.`)
      );
    }

    next();
  };
};

module.exports = authorize;
