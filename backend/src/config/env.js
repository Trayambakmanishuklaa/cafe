require('dotenv').config();

module.exports = {
  PORT: process.env.PORT || 5000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  DATABASE_URL: process.env.DATABASE_URL,
  JWT_SECRET: process.env.JWT_SECRET || 'fallback_jwt_secret_key_2026',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  CORS_ORIGIN: process.env.CORS_ORIGIN || '*',
  PAYMENT_GATEWAY_KEY_ID: process.env.PAYMENT_GATEWAY_KEY_ID || 'rzp_test_sample',
  PAYMENT_GATEWAY_KEY_SECRET: process.env.PAYMENT_GATEWAY_KEY_SECRET || 'sample_secret',
};
