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

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "hello-api"
    ManagedBy   = "terraform"
    Owner       = "infrastructure-team"
  }
}
