variable "cluster_name" {
  description = "Name prefix for secrets"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "redis_endpoint" {
  description = "Redis endpoint"
  type        = string
}
