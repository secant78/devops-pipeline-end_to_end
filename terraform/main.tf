terraform {
  backend "s3" {
    bucket         = "sean-terraform-state-devops-pipeline-end-to-end"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"           # Must match your project region
    use_lockfile = true             # Replaces dynamodb_table for native locking
    encrypt      = true
  }
}