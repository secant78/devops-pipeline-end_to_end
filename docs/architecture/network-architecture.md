# Network Architecture

## Overview
Multi-AZ VPC deployment in us-east-2 with public and private subnet tiers.

## Network Topology

```
                    ┌─────────────────────────────────────┐
                    │           AWS Cloud (us-east-2)      │
                    │                                       │
                    │  ┌──────────────────────────────────┐ │
                    │  │      VPC: 10.0.0.0/16            │ │
                    │  │                                    │ │
    Internet ──────►│  │  ┌─── Public Subnets ───────────┐│ │
         │          │  │  │ 10.0.101.0/24 (us-east-2a)   ││ │
         │          │  │  │ 10.0.102.0/24 (us-east-2b)   ││ │
         │          │  │  │ 10.0.103.0/24 (us-east-2c)   ││ │
         │          │  │  │                                ││ │
         │          │  │  │  [ALB/Ingress] [NAT Gateway]  ││ │
         │          │  │  └────────────┬───────────────────┘│ │
         │          │  │               │                    │ │
    CloudFront      │  │  ┌─── Private Subnets ──────────┐│ │
    (CDN) ─────────►│  │  │ 10.0.1.0/24 (us-east-2a)    ││ │
         │          │  │  │ 10.0.2.0/24 (us-east-2b)    ││ │
         │          │  │  │ 10.0.3.0/24 (us-east-2c)    ││ │
    WAF ────────────┤  │  │                                ││ │
                    │  │  │  [EKS Nodes] [RDS] [Redis]   ││ │
                    │  │  └────────────────────────────────┘│ │
                    │  └──────────────────────────────────┘ │
                    └─────────────────────────────────────┘
```

## Security Groups

| Resource     | Inbound                     | Outbound    |
|-------------|----------------------------|-------------|
| ALB         | 443 (HTTPS) from 0.0.0.0/0 | All traffic |
| EKS Nodes   | 443, 10250 from VPC CIDR    | All traffic |
| RDS         | 5432 from VPC CIDR          | All traffic |
| ElastiCache | 6379 from VPC CIDR          | All traffic |

## Key Design Decisions
- Single NAT Gateway for cost optimization (multi-NAT for production HA)
- Private subnets for all compute/data resources
- Public subnets only for ALB and NAT Gateway
- VPC CIDR /16 allows for future expansion
- Three AZs for high availability
