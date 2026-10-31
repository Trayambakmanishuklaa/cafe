const jwt = require('jsonwebtoken');
const env = require('../config/env');
const prisma = require('../database/prisma');
const { ApiError } = require('./errorHandler');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new ApiError(401, 'Authentication token is required');
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, env.JWT_SECRET);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        name: true,
        phone: true,
        role: true,
      },
    });

    if (!user) {
      throw new ApiError(401, 'User account no longer exists');
    }

    let role = user.role;
    if (user.email.toLowerCase() === 'admin@cafe.com') {
      role = 'ADMIN';
    } else if (user.email.toLowerCase() === 'staff@cafe.com') {
      role = 'STAFF';
    }

    req.user = { ...user, role };
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return next(new ApiError(401, 'Invalid or expired token'));
    }
    next(error);
  }
};

module.exports = authenticate;
