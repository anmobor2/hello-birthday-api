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

variable "github_repository" {
  description = "GitHub repository name (e.g., 'username/repo')"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy from"
  type        = string
}

variable "ecr_repository_uri" {
  description = "URI of the ECR repository"
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

variable "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "sonar_token" {
  description = "SonarQube token (can be stored in SSM Parameter Store)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "production_approval_url" {
  description = "URL to display in the production approval stage (e.g., link to SonarQube results)"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}