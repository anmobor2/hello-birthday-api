# Store Terraform state in an S3 bucket with a separate path for production
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}