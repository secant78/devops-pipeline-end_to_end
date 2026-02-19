variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "ecommerce-prod"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "ecomadmin"
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
