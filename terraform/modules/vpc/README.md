# AWS VPC Module for E-Commerce Pipeline

This module provisions a production-ready VPC in **us-east-2** with:
* 3 Public Subnets (for ALBs/NAT)
* 3 Private Subnets (for EKS Nodes/RDS)
* NAT Gateway for outbound internet access from private subnets

## Usage
```hcl
module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "my-ecommerce-vpc"
}
```