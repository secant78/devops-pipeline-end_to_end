terraform {
  backend "s3" {
    bucket       = "sean-terraform-state-devops-pipeline-end-to-end"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "ecommerce-prod-vpc"
  cidr = "10.0.0.0/16"

  # 2 AZs instead of 3 - reduces NAT/subnet costs while keeping HA
  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Single NAT gateway (~$32/mo vs ~$96/mo for one per AZ)
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name       = "ecommerce-prod"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets
  ecr_registry       = var.ecr_registry
  aws_region         = var.aws_region
}
