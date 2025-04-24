# Production environment configuration

locals {
  environment = "pro"
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
  availability_zones  = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]  # Use 3 AZs for production
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  # Production-specific settings
  enable_nat_gateway  = true
  single_nat_gateway  = false  # Use multiple NAT Gateways for high availability
  enable_https        = true   # HTTPS for production environment

  common_tags         = var.common_tags
}

# IAM module - Creates IAM roles and policies
module "iam" {
  source = "../../modules/iam"

  project_name        = var.project_name
  environment         = local.environment
  aws_region          = var.aws_region

  # Production-specific settings
  enable_secretsmanager = true
  secretsmanager_resource_pattern = "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.project_name}-${local.environment}-*"

  # Additional managed policies for production
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
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
  target_port         = var.container_port
  health_check_path   = "/health"

  # Production-specific settings
  internal            = false
  enable_deletion_protection = true
  enable_https        = true
  ssl_certificate_arn = var.ssl_certificate_arn

  # Domain configuration
  domain_name         = var.domain_name
  route53_zone_id     = var.route53_zone_id
  create_dns_record   = true
  # For production, we don't use a prefix (use apex domain)
  environment_prefix  = ""

  common_tags         = var.common_tags
}

# ECS cluster module
module "ecs" {
  source = "../../modules/ecs"

  project_name        = var.project_name
  environment         = local.environment
  aws_region          = var.aws_region
  vpc_id              = module.networking.vpc_id
  private_subnets     = module.networking.private_subnets
  ecs_security_group_id = module.networking.ecs_security_group_id

  # Production-specific settings
  container_image     = "${var.ecr_repository_url}:${var.container_image_tag}"
  container_port      = var.container_port
  container_cpu       = var.container_cpu        # Higher CPU for production
  container_memory    = var.container_memory     # Higher memory for production
  desired_count       = var.desired_count        # Multiple tasks for high availability

  # Link to other resources
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn        = module.iam.task_role_arn
  target_group_arn     = module.loadbalancer.target_group_arn

  # Environment variables specific to production
  environment_variables = [
    {
      name  = "APP_ENVIRONMENT"
      value = "production"
    },
    {
      name  = "LOG_LEVEL"
      value = "INFO"
    }
  ]

  # Production-specific auto-scaling
  enable_autoscaling  = true
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  cpu_scaling_target  = 70

  common_tags         = var.common_tags

  depends_on = [module.networking, module.iam]
}

# Monitoring with enhanced settings for production
module "monitoring" {
  source = "../../modules/monitoring"

  project_name        = var.project_name
  environment         = local.environment
  aws_region          = var.aws_region

  # ECS monitoring
  ecs_cluster_name    = module.ecs.ecs_cluster_name
  ecs_service_name    = module.ecs.ecs_service_name

  # ALB monitoring
  alb_arn_suffix      = module.loadbalancer.alb_arn_suffix
  target_group_arn_suffix = module.loadbalancer.target_group_arn_suffix

  # Production-specific settings - stricter thresholds
  cpu_threshold       = 70
  memory_threshold    = 70
  error_threshold     = 2

  # Alerting
  create_sns_topic    = true
  alarm_email         = var.alarm_email
  enable_enhanced_monitoring = true

  common_tags         = var.common_tags
}

# Optional: WAF configuration for production
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = module.loadbalancer.alb_arn
  web_acl_arn  = var.waf_web_acl_arn

  # Only create if WAF ACL ARN is provided
  count = var.waf_web_acl_arn != "" ? 1 : 0
}

# Optional: CI/CD Pipeline for production
module "cicd" {
  source = "../../modules/cicd"
  count  = var.enable_cicd ? 1 : 0

  project_name         = var.project_name
  environment          = local.environment
  aws_region           = var.aws_region
  github_repository    = var.github_repository
  github_branch        = "main"  # Production pipeline uses main branch
  ecr_repository_uri   = var.ecr_repository_url
  ecs_cluster_name     = module.ecs.ecs_cluster_name
  ecs_service_name     = module.ecs.ecs_service_name
  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn        = module.iam.task_role_arn

  common_tags          = var.common_tags
}