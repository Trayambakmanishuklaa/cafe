const env = require('../config/env');

class ApiError extends Error {
  constructor(statusCode, message, errors = []) {
    super(message);
    this.statusCode = statusCode;
    this.errors = errors;
  }
}

const errorHandler = (err, req, res, next) => {
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal Server Error';
  let errors = err.errors || [];

  // Handle Prisma Known Request Errors & give proper, understandable messages
  if (err.code === 'P2002') {
    statusCode = 400;
    const target = err.meta?.target;
    if (Array.isArray(target) && target.includes('email')) {
      message = 'An account with this email address already exists.';
    } else if (Array.isArray(target) && target.includes('phone')) {
      message = 'An account with this mobile number already exists.';
    } else {
      message = `This ${target || 'record'} already exists in the system.`;
    }
  } else if (err.code === 'P2025') {
    statusCode = 404;
    message = 'Requested record was not found.';
  } else if (err.code && err.code.startsWith('P')) {
    statusCode = 400;
    message = `Database error (${err.code}): ${err.message.split('\n').pop()}`;
  }

  console.error(`[Error] ${req.method} ${req.url}:`, err);

  res.status(statusCode).json({
    success: false,
    message,
    errors,
    stack: env.NODE_ENV === 'development' ? err.stack : undefined,
  });
};

module.exports = {
  ApiError,
  errorHandler,
};
