const request = require('supertest');
const app = require('../index');

describe('GET /api/convert', () => {
  it('returns 400 for missing url', async () => {
    const res = await request(app).get('/api/convert');
    expect(res.status).toBe(400);
  });
});
