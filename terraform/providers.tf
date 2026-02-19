provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ecommerce-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "ecommerce-platform"
      Environment = var.environment
      ManagedBy   = "terraform"
      Region      = "dr"
    }
  }
}
