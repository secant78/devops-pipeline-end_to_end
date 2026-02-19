variable "cluster_name" {
  description = "Name prefix for monitoring resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for monitoring"
  type        = string
}
