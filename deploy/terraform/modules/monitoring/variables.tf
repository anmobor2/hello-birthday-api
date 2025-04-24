variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, pre, pro)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the load balancer"
  type        = string
  default     = ""
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group"
  type        = string
  default     = ""
}

variable "cpu_threshold" {
  description = "Threshold for CPU utilization alarm"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Threshold for memory utilization alarm"
  type        = number
  default     = 80
}

variable "error_threshold" {
  description = "Threshold for HTTP 5XX errors alarm"
  type        = number
  default     = 5
}

variable "create_sns_topic" {
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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_alb_alarm" {
  description = "Whether to enable ALB-related alarms"
  type        = bool
  default     = false
}

variable "enable_grafana" {
  description = "Whether to enable Amazon Managed Grafana"
  type        = bool
  default     = false
}

variable "grafana_admin_user_arns" {
  description = "List of ARNs of users/roles that should have Grafana admin permissions"
  type        = list(string)
  default     = []
}