# k6 Load Testing Tool

Installs k6, a modern load testing tool for developers and testers. This feature includes Node.js integration for JavaScript ecosystem compatibility.

## Example Usage

```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/ruanzx/features/k6:latest": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of k6 to install. Use 'latest' for the most recent version or specify a version like 'v0.54.0' | string | latest |

## Dependencies

This feature automatically installs after:
- **Node.js**: Required for JavaScript ecosystem compatibility and npm package management

## Description

k6 is a modern load testing tool, developed by Grafana Labs, that allows developers and testers to write performance tests in JavaScript. It's designed to test the performance of APIs, microservices, and websites with a focus on developer experience.

## Usage Examples

### Default Installation with Node.js (Recommended)
```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/ruanzx/features/k6:latest": {}
}
```

### Specific Version with Node.js LTS
```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {
        "nodeGypDependencies": true,
        "version": "lts"
    },
    "ghcr.io/ruanzx/features/k6:latest": {
        "version": "v0.54.0"
    }
}
```

### Complete Development Setup
```json
"features": {
    "ghcr.io/devcontainers/features/node:1": {
        "version": "lts"
    },
    "ghcr.io/ruanzx/features/k6:latest": {},
    "ghcr.io/ruanzx/features/apt:latest": {
        "packages": "curl,jq"
    }
}
```

## What is k6?

k6 is a free, developer-centric load testing tool built for making performance testing a productive and enjoyable experience.

### Key Features

- **JavaScript ES6+**: Write tests in modern JavaScript with full Node.js ecosystem support
- **Performance Testing**: Load, stress, spike, and volume testing
- **CI/CD Integration**: Built for automation and CI/CD pipelines
- **Cloud & On-premise**: Run tests locally or in the cloud
- **Rich Metrics**: Built-in metrics and custom metrics support
- **Multiple Protocols**: HTTP/1.1, HTTP/2, WebSockets, gRPC

### Node.js Integration Benefits

With Node.js installed as a dependency, you can:
- **Use npm packages**: Install and use JavaScript libraries for test utilities
- **Modular test code**: Organize tests using ES6 modules and npm packages
- **Data generation**: Use faker.js, moment.js, or other npm packages for test data
- **Test management**: Use package.json scripts for test automation
- **Development tools**: Access to the full JavaScript development ecosystem

### Common Use Cases

- **API load testing**: Test REST APIs and GraphQL endpoints
- **Website performance**: Test page load times and user interactions
- **Microservices testing**: Test service-to-service communication under load
- **CI/CD integration**: Automated performance testing in pipelines
- **Capacity planning**: Determine system limits and scaling requirements

## Getting Started

After installation, you can create and run k6 tests:

### 1. Create a Simple Test Script

Create a file called `test.js`:

```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export default function () {
  http.get('https://httpbin.test.k6.io/');
  sleep(1);
}
```

### 2. Run the Test

```bash
k6 run test.js
```

### 3. Run with Options

```bash
# Run with 10 virtual users for 30 seconds
k6 run --vus 10 --duration 30s test.js

# Run with stages (ramp-up/ramp-down)
k6 run --stage 2m:10 --stage 5m:10 --stage 2m:0 test.js
```

## Advanced Examples

### API Testing
```javascript
import http from 'k6/http';
import { check } from 'k6';

export default function () {
  const response = http.get('https://api.example.com/users');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

### Authentication Testing
```javascript
import http from 'k6/http';

export default function () {
  const loginResponse = http.post('https://api.example.com/login', {
    username: 'user',
    password: 'pass'
  });
  
  const token = loginResponse.json('token');
  
  http.get('https://api.example.com/protected', {
    headers: { Authorization: `Bearer ${token}` }
  });
}
```

## Test Configuration

You can configure your tests using options:

```javascript
export const options = {
  vus: 10, // 10 virtual users
  duration: '30s', // for 30 seconds
  
  // Or use stages for more complex scenarios
  stages: [
    { duration: '2m', target: 10 }, // Ramp up to 10 users over 2 minutes
    { duration: '5m', target: 10 }, // Stay at 10 users for 5 minutes
    { duration: '2m', target: 0 },  // Ramp down to 0 users over 2 minutes
  ],
  
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
  },
};
```

## CI/CD Integration

k6 is designed to work well in CI/CD pipelines:

```bash
# Exit with non-zero code if thresholds fail
k6 run --quiet test.js

# Generate JSON output for processing
k6 run --out json=results.json test.js

# Set thresholds via command line
k6 run --threshold http_req_duration=avg:200ms test.js
```

## Verification

After installation, verify k6 is working:

```bash
# Check version
k6 version

# Run a quick test
k6 run --vus 1 --duration 10s https://test.k6.io/contacts.php
```

## Documentation

- [k6 Documentation](https://k6.io/docs/)
- [JavaScript API](https://k6.io/docs/javascript-api/)
- [Examples](https://k6.io/docs/examples/)
- [Best Practices](https://k6.io/docs/testing-guides/test-types/)

## Troubleshooting

If k6 fails to install:

1. Check that the specified version exists on [GitHub releases](https://github.com/grafana/k6/releases)
2. Verify your system architecture is supported (amd64, arm64)
3. Ensure internet connectivity for downloading the binary
4. Check that you have sufficient permissions to install binaries

For the latest version information, visit the [k6 releases page](https://github.com/grafana/k6/releases).
