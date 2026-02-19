# Performance and Load Testing

## Tool: k6
We use [k6](https://k6.io/) for load testing the e-commerce platform.

## Running Load Tests

### Prerequisites
```bash
# Install k6
# macOS
brew install k6

# Linux
sudo apt-get install k6

# Windows
choco install k6
```

### Execute Tests
```bash
# Against local services
k6 run k6-load-test.js

# Against deployed environment
k6 run -e BASE_URL=https://<ALB_DNS_NAME> k6-load-test.js
```

## Test Scenarios

| Stage    | Duration | Virtual Users | Purpose              |
|---------|----------|---------------|----------------------|
| Ramp up | 1 min    | 0 -> 10       | Warm up              |
| Ramp up | 3 min    | 10 -> 50      | Normal load          |
| Steady  | 5 min    | 50            | Sustained load       |
| Spike   | 2 min    | 50 -> 100     | Stress test          |
| Steady  | 3 min    | 100           | Peak load            |
| Ramp down| 2 min   | 100 -> 0      | Graceful cooldown    |

## Success Criteria
- 95th percentile response time < 500ms
- Error rate < 5%
- All health checks pass
- No pod restarts during test

## Results
Results are output to `load-test-results.json` after each run.
