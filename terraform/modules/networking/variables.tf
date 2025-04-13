variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, pre, pro)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
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

variable "enable_https" {
  description = "Enable HTTPS on ALB"
  type        = bool
  default     = false
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8000
}

variable "common_tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
