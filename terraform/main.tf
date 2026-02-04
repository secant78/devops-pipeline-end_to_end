terraform {
  backend "s3" {
    bucket         = "secant78-terraform-state-devops-pipeline-end_to_end"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"           # Must match your project region
    dynamodb_table = "sean-terraform-lock"      # Required for state locking
    encrypt        = true                  # Best practice for security
  }
}