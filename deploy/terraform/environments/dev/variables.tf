variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hello-api"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "domain_name" {
  description = "The domain name for the application"
  type        = string
  default     = "hello-api.io"
}

variable "route53_zone_id" {
  description = "The Route53 hosted zone ID"
  type        = string
  default     = "Z3HELLOAPI5XAMPLE"
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "hello-api"
    ManagedBy   = "terraform"
  }
}
