# Performance Testing Environment

This example demonstrates a complete performance testing environment with k6 for load testing and performance analysis.

## Features Included

- **k6** - Modern load testing tool for performance testing
- **Node.js** - For additional scripting and tooling support

## VS Code Extensions

- JSON language support
- YAML language support  
- Tomorrow theme
- Jsonnet support for k6 configuration

## Getting Started

1. Open this folder in VS Code with the Dev Containers extension
2. Choose "Reopen in Container" when prompted
3. Wait for the container to build and k6 to install
4. Verify installation with: `k6 version`

## Example Usage

### 1. Simple Load Test

Create a basic test file `simple-test.js`:

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10, // 10 virtual users
  duration: '30s', // for 30 seconds
};

export default function () {
  const response = http.get('https://httpbin.org/get');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

Run the test:
```bash
k6 run simple-test.js
```

### 2. API Performance Test

Create an API test `api-test.js`:

```javascript
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 10 }, // Ramp up to 10 users
    { duration: '5m', target: 10 }, // Stay at 10 users
    { duration: '2m', target: 0 },  // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests under 500ms
    http_req_failed: ['rate<0.1'],    // Error rate under 10%
  },
};

export default function () {
  // Test GET endpoint
  const getResponse = http.get('https://jsonplaceholder.typicode.com/posts/1');
  check(getResponse, {
    'GET status is 200': (r) => r.status === 200,
    'GET has content': (r) => r.body.length > 0,
  });

  // Test POST endpoint
  const postData = {
    title: 'foo',
    body: 'bar',
    userId: 1,
  };
  
  const postResponse = http.post(
    'https://jsonplaceholder.typicode.com/posts',
    JSON.stringify(postData),
    {
      headers: { 'Content-Type': 'application/json' },
    }
  );
  
  check(postResponse, {
    'POST status is 201': (r) => r.status === 201,
    'POST returns id': (r) => JSON.parse(r.body).id !== undefined,
  });
}
```

### 3. Authentication Flow Test

Create an auth test `auth-test.js`:

```javascript
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 5,
  duration: '1m',
};

export default function () {
  // Login
  const loginResponse = http.post('https://httpbin.org/post', {
    username: 'testuser',
    password: 'testpass'
  });
  
  check(loginResponse, {
    'login successful': (r) => r.status === 200,
  });
  
  // Simulate getting auth token (in real scenario, extract from response)
  const token = 'fake-jwt-token';
  
  // Make authenticated request
  const authResponse = http.get('https://httpbin.org/bearer', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  
  check(authResponse, {
    'authenticated request successful': (r) => r.status === 200,
  });
}
```

## Advanced Features

### Environment Variables
Use environment variables for dynamic configuration:

```javascript
export const options = {
  vus: __ENV.VUS || 10,
  duration: __ENV.DURATION || '30s',
};

const BASE_URL = __ENV.BASE_URL || 'https://httpbin.org';
```

Run with environment variables:
```bash
k6 run -e VUS=20 -e DURATION=60s -e BASE_URL=https://api.example.com test.js
```

### Custom Metrics
Add custom metrics to your tests:

```javascript
import { Trend } from 'k6/metrics';

const customMetric = new Trend('custom_response_time');

export default function () {
  const start = Date.now();
  const response = http.get('https://httpbin.org/get');
  const duration = Date.now() - start;
  
  customMetric.add(duration);
}
```

### Data-Driven Testing
Use data files for testing:

```javascript
import { SharedArray } from 'k6/data';

const data = new SharedArray('users', function () {
  return JSON.parse(open('./users.json'));
});

export default function () {
  const user = data[Math.floor(Math.random() * data.length)];
  
  const response = http.post('https://httpbin.org/post', {
    username: user.username,
    email: user.email,
  });
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Performance Tests
on: [push, pull_request]

jobs:
  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run k6 load test
        uses: grafana/k6-action@v0.2.0
        with:
          filename: tests/performance-test.js
          flags: --vus 10 --duration 30s
```

### Docker Integration

```dockerfile
FROM grafana/k6:latest
COPY tests/ /tests/
CMD ["run", "/tests/load-test.js"]
```

## Results Analysis

k6 provides detailed metrics and can output results in various formats:

```bash
# JSON output for processing
k6 run --out json=results.json test.js

# CSV output
k6 run --out csv=results.csv test.js

# Send to InfluxDB
k6 run --out influxdb=http://localhost:8086/k6 test.js
```

## Best Practices

1. **Start Small**: Begin with a few virtual users and gradually increase
2. **Use Realistic Data**: Test with production-like data volumes
3. **Monitor Resources**: Watch CPU, memory, and network during tests
4. **Set Thresholds**: Define performance criteria for pass/fail
5. **Test Early**: Include performance tests in your development cycle

## Troubleshooting

Common issues and solutions:

- **High resource usage**: Reduce VUs or add sleep between requests
- **Network timeouts**: Increase timeout values or check network connectivity
- **Memory issues**: Use SharedArray for large datasets
- **SSL/TLS errors**: Configure TLS settings or use `--insecure-skip-tls-verify`

## Documentation

- [k6 Documentation](https://k6.io/docs/)
- [JavaScript API Reference](https://k6.io/docs/javascript-api/)
- [Testing Guides](https://k6.io/docs/testing-guides/)
- [Examples Repository](https://github.com/grafana/k6-example-scripts)

This environment provides everything you need to start performance testing with k6!
