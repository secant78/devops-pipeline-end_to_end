module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31" # Latest stable version

  # networking - linking to your VPC module outputs
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Security: Disable public access to the API server for a "Prod" feel
  cluster_endpoint_public_access = true 

  # Managed Node Groups (The "Appliances")
  eks_managed_node_groups = {
    general = {
      instance_types = ["t3.medium"] # Balanced cost/performance for dev
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  # Required for IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  tags = {
    Environment = "prod"
    Project     = "ecommerce-platform"
  }
}