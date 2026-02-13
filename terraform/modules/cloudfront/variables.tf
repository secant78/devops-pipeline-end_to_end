variable "cluster_name" {
  description = "Name prefix for CloudFront resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "waf_acl_arn" {
  description = "WAF Web ACL ARN to associate with CloudFront"
  type        = string
  default     = ""
}
