# Global shared resources that are used across all environments

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Backend configuration for global resources
terraform {
  backend "s3" {
    bucket         = "hello-api-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "hello-api-terraform-locks"
  }
}

# Shared ECR repository for all environments
resource "aws_ecr_repository" "hello_api" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Configure lifecycle policy to keep only the latest images
  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Keep only last 10 images"
          selection = {
            tagStatus     = "any"
            countType     = "imageCountMoreThan"
            countNumber   = 10
          }
          action = {
            type = "expire"
          }
        }
      ]
    })
  }

  tags = var.common_tags
}

# Shared KMS key for encrypting sensitive data across environments
resource "aws_kms_key" "hello_api" {
  description             = "${var.project_name} encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = var.common_tags
}

resource "aws_kms_alias" "hello_api" {
  name          = "alias/${var.project_name}"
  target_key_id = aws_kms_key.hello_api.key_id
}

# S3 bucket for storing Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = var.common_tags
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption on the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.common_tags
}