variable "cluster_name" {
  description = "Name prefix for WAF resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}
