const express = require('express');
const AuthController = require('./auth.controller');
const validate = require('../../middleware/validate');
const authenticate = require('../../middleware/authenticate');
const { registerSchema, loginSchema } = require('./auth.validation');

const router = express.Router();

router.post('/register', validate(registerSchema), AuthController.register);
router.post('/login', validate(loginSchema), AuthController.login);
router.get('/me', authenticate, AuthController.getProfile);

module.exports = router;
