# Store Terraform state in an S3 bucket with a separate path for each environment
terraform {
  backend "s3" {
    bucket         = "hello-api-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "hello-api-terraform-locks"
  }
}