# E-Commerce Platform API Documentation

## Base URL
```
https://<ALB_DNS_NAME>
```

## Authentication
All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### User Service

#### Register User
```
POST /api/users/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe"
}

Response 201:
{
  "message": "User registered successfully",
  "userId": "12345"
}
```

#### Login
```
POST /api/users/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securePassword123"
}

Response 200:
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

#### Get User Profile
```
GET /api/users/:id
Authorization: Bearer <token>

Response 200:
{
  "id": "12345",
  "name": "John Doe",
  "email": "user@example.com"
}
```

### Product Service

#### List Products
```
GET /api/products?category=electronics&page=1&limit=20

Response 200:
{
  "products": [...],
  "page": 1,
  "totalPages": 5
}
```

#### Get Product
```
GET /api/products/:id

Response 200:
{
  "id": "1",
  "name": "Product Name",
  "price": 29.99,
  "description": "...",
  "stock": 100
}
```

### Cart Service

#### Get Cart
```
GET /api/cart/:userId
Authorization: Bearer <token>

Response 200:
{
  "userId": "12345",
  "items": [
    { "productId": "1", "quantity": 2, "price": 29.99 }
  ],
  "total": 59.98
}
```

#### Add Item to Cart
```
POST /api/cart/:userId/items
Authorization: Bearer <token>
Content-Type: application/json

{
  "productId": "1",
  "quantity": 2
}

Response 201:
{
  "message": "Item added to cart"
}
```

### Payment Service

#### Process Payment
```
POST /api/payments
Authorization: Bearer <token>
Content-Type: application/json

{
  "orderId": "order-123",
  "amount": 99.99,
  "method": "credit_card"
}

Response 201:
{
  "message": "Payment processed",
  "paymentId": "pay-456",
  "status": "completed"
}
```

### Order Service

#### Create Order
```
POST /api/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "12345",
  "items": [
    { "productId": "1", "quantity": 2 }
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Columbus",
    "state": "OH",
    "zip": "43215"
  }
}

Response 201:
{
  "message": "Order created",
  "orderId": "order-789",
  "status": "pending"
}
```

## Health Checks
All services expose a health endpoint:
```
GET /health

Response 200:
{
  "status": "healthy",
  "service": "<service-name>",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Metrics
All services expose Prometheus metrics:
```
GET /metrics
```

## Error Responses
```json
{
  "error": "Description of the error"
}
```

| Status Code | Meaning                |
|------------|------------------------|
| 400        | Bad Request            |
| 401        | Unauthorized           |
| 404        | Not Found              |
| 500        | Internal Server Error  |
