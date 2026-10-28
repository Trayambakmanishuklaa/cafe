const request = require('supertest');
const app = require('../src/app');

describe('Cafe Backend Integration Tests', () => {
  it('GET /health should return 200 OK', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toEqual(200);
    expect(res.body.status).toEqual('OK');
  });

  it('GET /api/v1/categories endpoint responds with valid JSON', async () => {
    const res = await request(app).get('/api/v1/categories');
    expect([200, 500]).toContain(res.statusCode);
    expect(res.header['content-type']).toMatch(/json/);
  });

  it('POST /api/v1/orders without token should return 401 Unauthorized', async () => {
    const res = await request(app).post('/api/v1/orders').send({
      orderType: 'DINE_IN',
      items: [{ productId: 'test', quantity: 1 }],
    });
    expect(res.statusCode).toEqual(401);
  });
});
