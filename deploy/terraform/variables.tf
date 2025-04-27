# Project settings
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hello-api"
}

variable "environment" {
  description = "Deployment environment (dev, pre, pro)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

# Network settings
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private networks"
  type        = bool
  default     = true
}

# Container settings
variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "container_image_tag" {
  description = "Tag of the container image to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "The amount of memory (in MiB) to reserve for the container"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "container_environment_variables" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default     = [
    {
      name  = "APP_ENVIRONMENT"
      value = "development"
    }
  ]
}

# Auto-scaling settings
variable "enable_autoscaling" {
  description = "Whether to enable auto scaling for the ECS service"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum number of tasks to run"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of tasks to run"
  type        = number
  default     = 4
}

variable "cpu_scaling_target" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 70
}

# Load balancer settings
variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "alb_internal" {
  description = "Whether the load balancer is internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

variable "enable_https" {
  description = "Whether to enable HTTPS on the load balancer"
  type        = bool
  default     = false
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate to use for HTTPS"
  type        = string
  default     = ""
}

# DNS settings
variable "domain_name" {
  description = "Domain name for the load balancer"
  type        = string
  default     = "hello-api.io"
}

variable "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  type        = string
  default     = "Z3HELLOAPI5XAMPLE"
}

variable "create_dns_record" {
  description = "Whether to create a DNS record for the load balancer"
  type        = bool
  default     = true
}

# Monitoring settings
variable "cpu_alarm_threshold" {
  description = "Threshold for CPU utilization alarm"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Threshold for memory utilization alarm"
  type        = number
  default     = 80
}

variable "error_alarm_threshold" {
  description = "Threshold for HTTP 5XX errors alarm"
  type        = number
  default     = 5
}

variable "create_alarm_topic" {
  description = "Whether to create an SNS topic for alarms"
  type        = bool
  default     = true
}

variable "alarm_email" {
  description = "Email address to send alarm notifications to"
  type        = string
  default     = ""
}

variable "enable_enhanced_monitoring" {
  description = "Whether to enable enhanced monitoring"
  type        = bool
  default     = false
}

# IAM settings
variable "enable_secretsmanager" {
  description = "Whether to enable Secrets Manager permissions"
  type        = bool
  default     = false
}

# Tagging
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "hello-api"
    ManagedBy   = "terraform"
  }
}

variable "grafana_admin_user_arns" {
  description = "List of ARNs of users/roles that should have Grafana admin permissions"
  type        = list(string)
  default     = []
}

variable "enable_cicd" {
  description = "Whether to enable CI/CD pipeline for this environment"
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository name (e.g. 'usuario/repo')"
  type        = string
  default     = ""
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the ALB"
  type        = string
  default     = ""
}

