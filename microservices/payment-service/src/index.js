const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { register, collectDefaultMetrics } = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3004;

collectDefaultMetrics();

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'payment-service', timestamp: new Date().toISOString() });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Payment routes
app.post('/api/payments', async (req, res) => {
  try {
    const { orderId, amount, method } = req.body;
    // Process payment and publish SNS event
    res.status(201).json({
      message: 'Payment processed',
      paymentId: Date.now().toString(),
      status: 'completed',
      orderId,
      amount
    });
  } catch (error) {
    res.status(500).json({ error: 'Payment processing failed' });
  }
});

app.get('/api/payments/:id', async (req, res) => {
  try {
    res.json({
      id: req.params.id,
      orderId: 'order-123',
      amount: 99.99,
      status: 'completed',
      method: 'credit_card'
    });
  } catch (error) {
    res.status(404).json({ error: 'Payment not found' });
  }
});

app.post('/api/payments/:id/refund', async (req, res) => {
  try {
    res.json({ message: 'Refund initiated', paymentId: req.params.id, status: 'refunding' });
  } catch (error) {
    res.status(500).json({ error: 'Refund failed' });
  }
});

app.get('/api/payments/order/:orderId', async (req, res) => {
  try {
    res.json({ orderId: req.params.orderId, payments: [], totalPaid: 0 });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch payments' });
  }
});

app.listen(PORT, () => {
  console.log(`Payment service running on port ${PORT}`);
});

module.exports = app;
