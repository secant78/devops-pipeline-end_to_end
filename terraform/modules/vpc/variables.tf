variable "vpc_name" {
  description = "Name of the VPC"
  type        = "string"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = "string"
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones for the region"
  type        = "list(string)"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = "list(string)"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = "list(string)"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}