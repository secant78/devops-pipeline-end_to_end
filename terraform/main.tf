terraform {
  backend "s3" {
    bucket         = "sean-terraform-state-devops-pipeline-end-to-end"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"           # Must match your project region
    dynamodb_table = "sean-terraform-lock"      # Required for state locking
    encrypt        = true                  # Best practice for security
  }
}