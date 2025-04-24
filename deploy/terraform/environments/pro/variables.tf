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
  default     = "10.1.0.0/16"  # Different CIDR for production
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

variable "container_image_tag" {
  description = "Tag of the container image to deploy"
  type        = string
  default     = "pro-latest"  # Use production-specific tag
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8000
}

# Enhanced resources for production
variable "container_cpu" {
  description = "The number of cpu units to reserve for the container"
  type        = number
  default     = 512  # More CPU for production
}

variable "container_memory" {
  description = "The amount of memory (in MiB) to reserve for the container"
  type        = number
  default     = 1024  # More memory for production
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 2  # Multiple tasks for high availability
}

# Auto-scaling settings
variable "min_capacity" {
  description = "Minimum number of tasks to run"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks to run"
  type        = number
  default     = 6  # Allow scaling up for higher traffic
}

# Security enhancement for production
variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate to use for HTTPS"
  type        = string
  default     = ""
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the ALB"
  type        = string
  default     = ""
}

# Monitoring and alerting
variable "alarm_email" {
  description = "Email address to send alarm notifications to"
  type        = string
  default     = "production-team@example.com"
}

# CI/CD configuration
variable "enable_cicd" {
  description = "Whether to enable CI/CD pipeline for this environment"
  type        = bool
  default     = true
}

variable "github_repository" {
  description = "GitHub repository name (e.g., 'username/repo')"
  type        = string
  default     = "username/hello-api"
}

# Common tags to apply to all resources
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "hello-api"
    ManagedBy   = "terraform"
    Owner       = "production-team"
    CostCenter  = "prod-67890"
    DataClassification = "internal"
  }
}