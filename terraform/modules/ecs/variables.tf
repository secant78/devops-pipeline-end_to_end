variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB (used to allow ALB -> task traffic)"
  type        = string
  default     = "" # Bootstrapped internally; passed after alb SG is created
}

variable "ecr_registry" {
  description = "ECR registry URL (e.g. 123456789.dkr.ecr.us-east-2.amazonaws.com)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
