# Application Architecture

## Microservices Overview

```
                         ┌──────────────┐
                         │  CloudFront  │
                         │    (CDN)     │
                         └──────┬───────┘
                                │
                         ┌──────▼───────┐
                         │  AWS WAF     │
                         └──────┬───────┘
                                │
                    ┌───────────▼────────────┐
                    │   ALB / API Gateway    │
                    │  (Kubernetes Ingress)  │
                    └───┬───┬───┬───┬───┬───┘
                        │   │   │   │   │
           ┌────────────┘   │   │   │   └────────────┐
           │        ┌───────┘   │   └───────┐        │
           ▼        ▼           ▼           ▼        ▼
     ┌──────────┐┌──────────┐┌──────────┐┌──────────┐┌──────────┐
     │  User    ││ Product  ││  Cart    ││ Payment  ││  Order   │
     │ Service  ││ Service  ││ Service  ││ Service  ││ Service  │
     │ :3001    ││ :3002    ││ :3003    ││ :3004    ││ :3005    │
     └────┬─────┘└────┬─────┘└────┬─────┘└────┬─────┘└────┬─────┘
          │           │           │           │           │
          └───────┬───┘           │           └─────┬─────┘
                  │               │                 │
           ┌──────▼───────┐ ┌────▼─────┐   ┌──────▼───────┐
           │  PostgreSQL  │ │  Redis   │   │  SNS / SQS   │
           │   (RDS)      │ │(ElastiC.)│   │  (Events)    │
           │  + Replica   │ │          │   │              │
           └──────────────┘ └──────────┘   └──────────────┘
```

## Service Responsibilities

| Service         | Port | Database | Purpose                              |
|----------------|------|----------|--------------------------------------|
| user-service   | 3001 | RDS      | Authentication, user profiles        |
| product-service| 3002 | RDS      | Product catalog, inventory           |
| cart-service   | 3003 | Redis    | Shopping cart, session management     |
| payment-service| 3004 | RDS      | Payment processing, refunds          |
| order-service  | 3005 | RDS      | Order lifecycle, status tracking      |

## Event-Driven Communication

```
order-service ──publish──► SNS: order-events ──► SQS: order-processing ──► payment-service
payment-service ──publish──► SNS: payment-events ──► SQS: payment-processing ──► order-service
product-service ──publish──► SNS: inventory-events ──► SQS: notifications
```

## API Endpoints

### User Service
- `POST /api/users/register` - Register new user
- `POST /api/users/login` - Authenticate user
- `GET /api/users/:id` - Get user profile
- `PUT /api/users/:id` - Update user profile

### Product Service
- `GET /api/products` - List products (paginated)
- `GET /api/products/:id` - Get product details
- `POST /api/products` - Create product
- `PUT /api/products/:id` - Update product
- `DELETE /api/products/:id` - Delete product

### Cart Service
- `GET /api/cart/:userId` - Get user's cart
- `POST /api/cart/:userId/items` - Add item to cart
- `PUT /api/cart/:userId/items/:productId` - Update cart item
- `DELETE /api/cart/:userId/items/:productId` - Remove item
- `DELETE /api/cart/:userId` - Clear cart

### Payment Service
- `POST /api/payments` - Process payment
- `GET /api/payments/:id` - Get payment details
- `POST /api/payments/:id/refund` - Initiate refund
- `GET /api/payments/order/:orderId` - Get payments for order

### Order Service
- `POST /api/orders` - Create order
- `GET /api/orders/:id` - Get order details
- `GET /api/orders/user/:userId` - Get user's orders
- `PUT /api/orders/:id/status` - Update order status
- `POST /api/orders/:id/cancel` - Cancel order
