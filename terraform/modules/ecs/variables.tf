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

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "ID of the security group for ECS service"
  type        = string
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
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

variable "task_execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group for load balancing"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default     = []
}

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

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}