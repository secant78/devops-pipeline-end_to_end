const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { register, collectDefaultMetrics } = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3003;

collectDefaultMetrics();

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'cart-service', timestamp: new Date().toISOString() });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Cart routes (session-backed with Redis)
app.get('/api/cart/:userId', async (req, res) => {
  try {
    res.json({ userId: req.params.userId, items: [], total: 0 });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch cart' });
  }
});

app.post('/api/cart/:userId/items', async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    res.status(201).json({ message: 'Item added to cart', productId, quantity });
  } catch (error) {
    res.status(500).json({ error: 'Failed to add item' });
  }
});

app.put('/api/cart/:userId/items/:productId', async (req, res) => {
  try {
    const { quantity } = req.body;
    res.json({ message: 'Cart item updated', productId: req.params.productId, quantity });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update item' });
  }
});

app.delete('/api/cart/:userId/items/:productId', async (req, res) => {
  try {
    res.json({ message: 'Item removed from cart', productId: req.params.productId });
  } catch (error) {
    res.status(500).json({ error: 'Failed to remove item' });
  }
});

app.delete('/api/cart/:userId', async (req, res) => {
  try {
    res.json({ message: 'Cart cleared', userId: req.params.userId });
  } catch (error) {
    res.status(500).json({ error: 'Failed to clear cart' });
  }
});

app.listen(PORT, () => {
  console.log(`Cart service running on port ${PORT}`);
});

module.exports = app;
