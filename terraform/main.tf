terraform {
  backend "s3" {
    bucket         = "sean-terraform-state-devops-pipeline-end-to-end"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"           # Must match your project region
    use_lockfile = true             # Replaces dynamodb_table for native locking
    encrypt      = true
  }
}

# --- RDS PostgreSQL with Read Replica ---
module "rds" {
  source             = "./modules/rds"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  vpc_cidr           = module.vpc.vpc_cidr_block
  db_username        = var.db_username
  db_password        = var.db_password
  environment        = var.environment
}

# --- ElastiCache Redis for Session Management ---
module "elasticache" {
  source             = "./modules/elasticache"
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  vpc_cidr           = module.vpc.vpc_cidr_block
  environment        = var.environment
}

# --- WAF for API Protection (Shield Standard included at no cost) ---
module "waf" {
  source       = "./modules/waf"
  cluster_name = var.cluster_name
  environment  = var.environment
}

# --- CloudFront CDN ---
module "cloudfront" {
  source       = "./modules/cloudfront"
  cluster_name = var.cluster_name
  environment  = var.environment
  waf_acl_arn  = module.waf.web_acl_arn
}

# --- SQS/SNS Event-Driven Messaging ---
module "messaging" {
  source       = "./modules/messaging"
  cluster_name = var.cluster_name
  environment  = var.environment
}

# --- Secrets Manager ---
module "secrets" {
  source         = "./modules/secrets"
  cluster_name   = var.cluster_name
  environment    = var.environment
  db_username    = var.db_username
  db_password    = var.db_password
  db_endpoint    = module.rds.db_endpoint
  redis_endpoint = module.elasticache.redis_endpoint
}

# --- CloudWatch Monitoring ---
module "monitoring" {
  source                     = "./modules/monitoring"
  cluster_name               = var.cluster_name
  environment                = var.environment
  aws_region                 = var.aws_region
  cloudfront_distribution_id = module.cloudfront.distribution_id
}
