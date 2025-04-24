variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, pre, pro)"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the security group for ALB"
  type        = string
}

variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 8000
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Interval between health checks in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health checks in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required to consider target healthy"
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health checks failures required to consider target unhealthy"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
}

variable "internal" {
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

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = ""
}

variable "ecs_service_id" {
  description = "ID of the ECS service"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the load balancer"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  type        = string
  default     = ""
}

variable "create_dns_record" {
  description = "Whether to create a DNS record for the load balancer"
  type        = bool
  default     = false
}

variable "environment_prefix" {
  description = "Prefix to add to the domain name for environment-specific subdomains"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}