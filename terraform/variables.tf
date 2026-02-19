variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "ecr_registry" {
  description = "ECR registry base URL (e.g. 123456789012.dkr.ecr.us-east-2.amazonaws.com)"
  type        = string
}
