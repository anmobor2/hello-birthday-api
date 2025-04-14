terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Note: The actual backend configuration is in each environment's backend.tf file
  # environments/dev/backend.tf, environments/pre/backend.tf, etc.
}

# Original AWS provider configuration (commented for LocalStack testing)
# provider "aws" {
#   region = var.aws_region
#
#   default_tags {
#     tags = {
#       Environment = var.environment
#       Project     = var.project_name
#       ManagedBy   = "terraform"
#     }
#   }
# }

# LocalStack provider configuration for local testing
provider "aws" {
  region                      = var.aws_region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  # Keep the original default tags
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }

  # LocalStack endpoints
  endpoints {
    acm                  = "http://localhost:4566"
    apigateway           = "http://localhost:4566"
    cloudformation       = "http://localhost:4566"
    cloudwatch           = "http://localhost:4566"
    dynamodb             = "http://localhost:4566"
    ec2                  = "http://localhost:4566"
    ecr                  = "http://localhost:4566"
    ecs                  = "http://localhost:4566"
    elasticloadbalancing = "http://localhost:4566"
    iam                  = "http://localhost:4566"
    route53              = "http://localhost:4566"
    s3                   = "http://localhost:4566"
    secretsmanager       = "http://localhost:4566"
    sns                  = "http://localhost:4566"
    sqs                  = "http://localhost:4566"
    sts                  = "http://localhost:4566"
  }
}