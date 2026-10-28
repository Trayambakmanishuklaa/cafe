const request = require('supertest');
const app = require('../src/app');

describe('Auth Endpoints Health & Validation', () => {
  it('GET /health should return status OK', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('OK');
  });

  it('POST /api/v1/auth/login with empty body should fail validation', async () => {
    const res = await request(app).post('/api/v1/auth/login').send({});
    expect(res.statusCode).toEqual(400);
    expect(res.body.success).toBe(false);
  });
});
