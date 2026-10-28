const { ApiError } = require('./errorHandler');

const validate = (schema) => (req, res, next) => {
  try {
    const parsed = schema.parse({
      body: req.body,
      query: req.query,
      params: req.params,
    });
    req.body = parsed.body || req.body;
    req.query = parsed.query || req.query;
    req.params = parsed.params || req.params;
    next();
  } catch (error) {
    if (error.errors) {
      const formattedErrors = error.errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      return next(new ApiError(400, 'Validation Failed', formattedErrors));
    }
    next(error);
  }
};

module.exports = validate;
