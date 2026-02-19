variable "cluster_name" {
  description = "Name prefix for RDS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DB subnet group"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block for security group rules"
  type        = string
}

variable "db_username" {
  description = "Master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}
