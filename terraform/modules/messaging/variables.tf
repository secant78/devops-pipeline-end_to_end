variable "cluster_name" {
  description = "Name prefix for messaging resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}
