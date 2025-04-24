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

variable "enable_secretsmanager" {
  description = "Whether to enable Secrets Manager permissions"
  type        = bool
  default     = false
}

variable "secretsmanager_resource_pattern" {
  description = "Resource pattern for Secrets Manager permissions"
  type        = string
  default     = "arn:aws:secretsmanager:*:*:secret:*"
}

variable "additional_task_policies" {
  description = "Additional policy statements for the task role"
  type        = list(any)
  default     = []
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the task role"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}