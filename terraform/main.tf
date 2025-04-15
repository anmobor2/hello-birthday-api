# Main Terraform configuration file - Calls all modules

# Networking module - Creates VPC, subnets, and security groups
module "networking" {
  source = "./modules/networking"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones  = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

  enable_nat_gateway  = var.enable_nat_gateway
  single_nat_gateway  = var.single_nat_gateway
  enable_https        = var.enable_https
  container_port      = var.container_port

  common_tags         = var.common_tags
}

# IAM module - Creates roles and policies
module "iam" {
  source = "./modules/iam"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region

  enable_secretsmanager = var.enable_secretsmanager
  secretsmanager_resource_pattern = "arn:aws:secretsmanager:${var.aws_region}:*:secret:${var.project_name}-*"

  common_tags        = var.common_tags
}

# ECS module - Creates ECS cluster, task definition, and service
module "ecs" {
  source = "./modules/ecs"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  vpc_id              = module.networking.vpc_id
  private_subnets     = module.networking.private_subnets
  ecs_security_group_id = module.networking.ecs_security_group_id

  container_image     = "${var.ecr_repository_url}:${var.container_image_tag}"
  container_port      = var.container_port
  container_cpu       = var.container_cpu
  container_memory    = var.container_memory
  desired_count       = var.desired_count

  task_execution_role_arn = module.iam.task_execution_role_arn
  task_role_arn        = module.iam.task_role_arn
  target_group_arn     = module.loadbalancer.target_group_arn

  environment_variables = var.container_environment_variables

  enable_autoscaling  = var.enable_autoscaling
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  cpu_scaling_target  = var.cpu_scaling_target

  common_tags         = var.common_tags

  depends_on = [module.networking, module.iam]
}

# Load balancer module - Creates ALB, target groups, and listeners
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  public_subnets      = module.networking.public_subnets
  alb_security_group_id = module.networking.alb_security_group_id

  target_port         = var.container_port
  health_check_path   = var.health_check_path

  internal            = var.alb_internal
  enable_deletion_protection = var.enable_deletion_protection
  enable_https        = var.enable_https
  ssl_certificate_arn = var.ssl_certificate_arn

  ecs_service_name    = module.ecs.ecs_service_name
  ecs_service_id      = module.ecs.ecs_service_id

  domain_name         = var.domain_name
  route53_zone_id     = var.route53_zone_id
  create_dns_record   = var.create_dns_record
  environment_prefix  = var.environment == "prod" ? "" : "${var.environment}-"

  common_tags         = var.common_tags

  depends_on = [module.networking]
}

# Monitoring module - Creates CloudWatch alarms, dashboard, and SNS topics
module "monitoring" {
  source = "./modules/monitoring"

  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region

  ecs_cluster_name    = module.ecs.ecs_cluster_name
  ecs_service_name    = module.ecs.ecs_service_name

  alb_arn_suffix      = module.loadbalancer.alb_arn_suffix
  target_group_arn_suffix = module.loadbalancer.target_group_arn_suffix

  cpu_threshold       = var.cpu_alarm_threshold
  memory_threshold    = var.memory_alarm_threshold
  error_threshold     = var.error_alarm_threshold

  # Alerting
  create_sns_topic    = var.create_alarm_topic
  alarm_email         = var.alarm_email
  enable_enhanced_monitoring = var.enable_enhanced_monitoring

  # Grafana (nueva adición)
  enable_grafana      = true
  grafana_admin_user_arns = var.grafana_admin_user_arns

  enable_alb_alarm    = true  # Asegurarte de activar las alarmas ALB

  common_tags         = var.common_tags

  depends_on = [module.ecs, module.loadbalancer]
}