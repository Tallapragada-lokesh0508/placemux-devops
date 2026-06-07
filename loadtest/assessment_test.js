import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '2m', target: 100  },
    { duration: '5m', target: 500  },
    { duration: '5m', target: 1000 },
    { duration: '3m', target: 500  },
    { duration: '2m', target: 0    },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    errors:            ['rate<0.01'],
  },
};

const BASE_URL = 'http://localhost:3000';

export default function () {
  const health = http.get(${BASE_URL}/health);
  check(health, {
    'health OK': (r) => r.status === 200,
  });
  errorRate.add(health.status !== 200);
  sleep(1);
}