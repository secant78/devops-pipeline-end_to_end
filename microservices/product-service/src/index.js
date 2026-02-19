const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { register, collectDefaultMetrics } = require('prom-client');

const app = express();
const PORT = process.env.PORT || 3002;

collectDefaultMetrics();

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'product-service', timestamp: new Date().toISOString() });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Product routes
app.get('/api/products', async (req, res) => {
  try {
    const { category, page = 1, limit = 20 } = req.query;
    res.json({
      products: [
        { id: '1', name: 'Sample Product', price: 29.99, category: 'electronics' }
      ],
      page: parseInt(page),
      totalPages: 1
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch products' });
  }
});

app.get('/api/products/:id', async (req, res) => {
  try {
    res.json({ id: req.params.id, name: 'Sample Product', price: 29.99, description: 'Product description', stock: 100 });
  } catch (error) {
    res.status(404).json({ error: 'Product not found' });
  }
});

app.post('/api/products', async (req, res) => {
  try {
    const { name, price, description, category } = req.body;
    res.status(201).json({ message: 'Product created', productId: Date.now().toString() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create product' });
  }
});

app.put('/api/products/:id', async (req, res) => {
  try {
    res.json({ message: 'Product updated', id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update product' });
  }
});

app.delete('/api/products/:id', async (req, res) => {
  try {
    res.json({ message: 'Product deleted', id: req.params.id });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete product' });
  }
});

app.listen(PORT, () => {
  console.log(`Product service running on port ${PORT}`);
});

module.exports = app;
