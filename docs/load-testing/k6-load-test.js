import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const errorRate = new Rate('errors');
const apiTrend = new Trend('api_response_time');

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3001';

export const options = {
  stages: [
    { duration: '1m', target: 10 },   // Ramp up to 10 users
    { duration: '3m', target: 50 },   // Ramp up to 50 users
    { duration: '5m', target: 50 },   // Stay at 50 users
    { duration: '2m', target: 100 },  // Spike to 100 users
    { duration: '3m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests under 500ms
    errors: ['rate<0.05'],              // Error rate under 5%
  },
};

export default function () {
  // Test 1: Health check
  let healthRes = http.get(`${BASE_URL}/health`);
  check(healthRes, {
    'health check status is 200': (r) => r.status === 200,
    'health check response time < 100ms': (r) => r.timings.duration < 100,
  });

  // Test 2: List products
  let productsRes = http.get(`${BASE_URL}/api/products?page=1&limit=20`);
  check(productsRes, {
    'products status is 200': (r) => r.status === 200,
    'products response time < 500ms': (r) => r.timings.duration < 500,
  });
  apiTrend.add(productsRes.timings.duration);
  errorRate.add(productsRes.status !== 200);

  // Test 3: Get single product
  let productRes = http.get(`${BASE_URL}/api/products/1`);
  check(productRes, {
    'product detail status is 200': (r) => r.status === 200,
  });

  // Test 4: User registration
  let registerPayload = JSON.stringify({
    email: `user${Math.random()}@test.com`,
    password: 'testpassword123',
    name: 'Load Test User',
  });
  let registerRes = http.post(`${BASE_URL}/api/users/register`, registerPayload, {
    headers: { 'Content-Type': 'application/json' },
  });
  check(registerRes, {
    'register status is 201': (r) => r.status === 201,
  });

  // Test 5: Create order
  let orderPayload = JSON.stringify({
    userId: 'user-123',
    items: [{ productId: '1', quantity: 2 }],
    shippingAddress: { street: '123 Test St', city: 'Columbus', state: 'OH', zip: '43215' },
  });
  let orderRes = http.post(`${BASE_URL}/api/orders`, orderPayload, {
    headers: { 'Content-Type': 'application/json' },
  });
  check(orderRes, {
    'order status is 201': (r) => r.status === 201,
  });
  errorRate.add(orderRes.status !== 201);

  sleep(1);
}

export function handleSummary(data) {
  return {
    'load-test-results.json': JSON.stringify(data, null, 2),
  };
}
