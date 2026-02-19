const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { register, collectDefaultMetrics } = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3001;

collectDefaultMetrics();

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'user-service', timestamp: new Date().toISOString() });
});

// Metrics endpoint for Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// User routes
app.post('/api/users/register', async (req, res) => {
  try {
    const { email, password, name } = req.body;
    // Registration logic with bcrypt hashing
    res.status(201).json({ message: 'User registered successfully', userId: Date.now().toString() });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed' });
  }
});

app.post('/api/users/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    // Authentication logic with JWT
    res.json({ message: 'Login successful', token: 'jwt-token-placeholder' });
  } catch (error) {
    res.status(401).json({ error: 'Authentication failed' });
  }
});

app.get('/api/users/:id', async (req, res) => {
  try {
    res.json({ id: req.params.id, name: 'Sample User', email: 'user@example.com' });
  } catch (error) {
    res.status(404).json({ error: 'User not found' });
  }
});

app.put('/api/users/:id', async (req, res) => {
  try {
    res.json({ message: 'User updated successfully', id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: 'Update failed' });
  }
});

app.listen(PORT, () => {
  console.log(`User service running on port ${PORT}`);
});

module.exports = app;
