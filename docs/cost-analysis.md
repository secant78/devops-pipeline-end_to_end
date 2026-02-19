# Cost Analysis and Optimization Report

## Monthly Cost Estimate (Cheapest Configuration)

| Resource                    | Type/Size           | Monthly Cost (USD) |
|----------------------------|--------------------|--------------------|
| **EKS Cluster**            | Control plane       | $73.00             |
| **EC2 (EKS Nodes)**        | 2x t3.medium        | $60.74             |
| **RDS Primary**            | db.t3.micro         | $12.41             |
| **RDS Read Replica**       | db.t3.micro         | $12.41             |
| **ElastiCache**            | cache.t3.micro      | $11.52             |
| **NAT Gateway**            | Single              | $32.40 + data      |
| **CloudFront**             | PriceClass_100      | $0.00 (free tier)  |
| **WAF**                    | Standard rules      | $11.00             |
| **S3 (State + Assets)**    | Standard            | $0.50              |
| **SQS**                    | Standard queues     | $0.00 (free tier)  |
| **SNS**                    | Standard topics     | $0.00 (free tier)  |
| **Secrets Manager**        | 3 secrets           | $1.20              |
| **CloudWatch**             | Logs + Metrics      | $5.00              |
| **ECR**                    | Container storage   | $1.00              |
| **ALB (Ingress)**          | Application LB      | $22.27             |
| **Shield Standard**        | DDoS protection     | $0.00 (free)       |
|                            |                     |                    |
| **TOTAL ESTIMATE**         |                     | **~$243/month**    |

## Cost Optimization Strategies Applied

### Compute
- **t3.medium** instances (cheapest viable for EKS workloads)
- Minimum 1 node, max 3 with auto-scaling
- Resource requests/limits set on all pods to maximize bin packing

### Database
- **db.t3.micro** - smallest RDS instance class
- Single-AZ deployment (multi-AZ would double cost)
- gp2 storage (20GB minimum)
- 7-day backup retention (minimum recommended)

### Caching
- **cache.t3.micro** - smallest ElastiCache node
- Single node (no replication for cost savings)

### Networking
- **Single NAT Gateway** instead of one per AZ (saves ~$65/month)
- **PriceClass_100** CloudFront - US/Canada/Europe only (cheapest)
- CloudFront default certificate (no ACM cost)

### Messaging
- SQS/SNS Standard tier (within free tier for low volume)
- Long polling enabled on SQS (reduces empty receives)

### Monitoring
- 14-day CloudWatch log retention (minimum useful period)
- ELK stack on EKS pods (no managed OpenSearch cost)
- Prometheus/Grafana self-hosted (no managed service cost)

### Security
- AWS Shield Standard (free, included)
- WAF Managed Rules (no custom rule development cost)
- Secrets Manager ($0.40/secret/month)

## Potential Savings if Needed

| Optimization                         | Savings     |
|-------------------------------------|-------------|
| Use Fargate Spot for non-critical   | ~30% compute|
| Reserved Instances (1yr)            | ~40% compute|
| Remove read replica                 | $12/month   |
| Reduce EKS nodes to 1              | $30/month   |
| Use VPC endpoints instead of NAT    | $32/month   |

## Scaling Cost Projections

| Scale Level  | Monthly Cost |
|-------------|-------------|
| Dev (1 node)| ~$180       |
| Current     | ~$243       |
| Medium (5 nodes)| ~$400  |
| Production (10 nodes, multi-AZ RDS)| ~$800 |
