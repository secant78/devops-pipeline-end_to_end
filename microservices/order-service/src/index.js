const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { register, collectDefaultMetrics } = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3005;

collectDefaultMetrics();

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'order-service', timestamp: new Date().toISOString() });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Order routes
app.post('/api/orders', async (req, res) => {
  try {
    const { userId, items, shippingAddress } = req.body;
    // Create order and publish to SNS order-events topic
    res.status(201).json({
      message: 'Order created',
      orderId: Date.now().toString(),
      status: 'pending',
      userId
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create order' });
  }
});

app.get('/api/orders/:id', async (req, res) => {
  try {
    res.json({
      id: req.params.id,
      userId: 'user-123',
      items: [],
      status: 'processing',
      total: 0,
      createdAt: new Date().toISOString()
    });
  } catch (error) {
    res.status(404).json({ error: 'Order not found' });
  }
});

app.get('/api/orders/user/:userId', async (req, res) => {
  try {
    res.json({ userId: req.params.userId, orders: [] });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

app.put('/api/orders/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    res.json({ message: 'Order status updated', orderId: req.params.id, status });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update order status' });
  }
});

app.post('/api/orders/:id/cancel', async (req, res) => {
  try {
    res.json({ message: 'Order cancelled', orderId: req.params.id, status: 'cancelled' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to cancel order' });
  }
});

app.listen(PORT, () => {
  console.log(`Order service running on port ${PORT}`);
});

module.exports = app;
