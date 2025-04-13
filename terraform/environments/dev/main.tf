# Development environment configuration

locals {
  environment = "dev"
}

provider "aws" {
  region = var.aws_region

  # Add default tags to all resources in this environment
  default_tags {
    tags = {
      Environment = local.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Network module - Creates VPC, subnets, security groups
module "networking" {
  source = "../../modules/networking"

  project_name        = var.project_name
  environment         = local.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

  # Development-specific settings
  enable_nat_gateway  = true
  single_nat_gateway  = true  # Use single NAT Gateway in dev to save costs
  enable_https        = false # HTTP only for dev environment

  common_tags         = var.common_tags
}

# ECS cluster module - Creates ECS cluster, service, tasks
module "ecs" {
  source = "../../modules/ecs"

  project_name        = var.project_name
  environment         = local.environment
  vpc_id              = module.networking.vpc_id
  private_subnets     = module.networking.private_subnets
  ecs_security_group_id = module.networking.ecs_security_group_id

  # Development-specific settings
  container_image     = "${var.ecr_repository_url}:latest"
  container_port      = 8000
  container_cpu       = 256
  container_memory    = 512
  desired_count       = 1  # Just one task in development

  # Environment variables specific to development
  environment_variables = [
    {
      name  = "APP_ENVIRONMENT"
      value = "development"
    },
    {
      name  = "LOG_LEVEL"
      value = "DEBUG"
    }
  ]

  common_tags         = var.common_tags
}

# Load balancer module
module "loadbalancer" {
  source = "../../modules/loadbalancer"

  project_name        = var.project_name
  environment         = local.environment
  vpc_id              = module.networking.vpc_id
  public_subnets      = module.networking.public_subnets
  alb_security_group_id = module.networking.alb_security_group_id

  # Target group
  target_port         = 8000
  health_check_path   = "/health"

  # Link to ECS service
  ecs_service_name    = module.ecs.ecs_service_name
  ecs_service_id      = module.ecs.ecs_service_id

  # Domain configuration
  domain_name         = var.domain_name
  route53_zone_id     = var.route53_zone_id
  create_dns_record   = true
  environment_prefix  = "dev-" # Creates dev-api.test.local

  common_tags         = var.common_tags
}

# Monitoring with lower thresholds for development
module "monitoring" {
  source = "../../modules/monitoring"

  project_name        = var.project_name
  environment         = local.environment

  # ECS monitoring
  ecs_cluster_name    = module.ecs.ecs_cluster_name
  ecs_service_name    = module.ecs.ecs_service_name

  # ALB monitoring
  alb_arn_suffix      = module.loadbalancer.alb_arn_suffix
  target_group_arn_suffix = module.loadbalancer.target_group_arn_suffix

  # Development-specific settings
  cpu_threshold       = 70    # Lower threshold for CPU alarm
  memory_threshold    = 70    # Lower threshold for memory alarm
  error_threshold     = 2     # Lower threshold for error alarm

  # Alerting
  create_sns_topic    = true
  alarm_email         = "dev-team@example.com"

  common_tags         = var.common_tags
}
