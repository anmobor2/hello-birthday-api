# Output values from all modules

# Network outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.networking.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.networking.public_subnets
}

# Load Balancer outputs
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.loadbalancer.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.loadbalancer.alb_zone_id
}

output "dns_record_name" {
  description = "The fully qualified domain name of the load balancer"
  value       = module.loadbalancer.dns_record_name
}

output "api_url" {
  description = "URL for the hello API"
  value       = "http://${module.loadbalancer.dns_record_name != null ? module.loadbalancer.dns_record_name : module.loadbalancer.alb_dns_name}"
}

# ECS outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.ecs.cloudwatch_log_group_name
}

# IAM outputs
output "task_execution_role_arn" {
  description = "The ARN of the task execution role"
  value       = module.iam.task_execution_role_arn
}

output "task_role_arn" {
  description = "The ARN of the task role"
  value       = module.iam.task_role_arn
}

# Monitoring outputs
output "monitoring_dashboard_name" {
  description = "The name of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_name
}

output "monitoring_sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms"
  value       = module.monitoring.sns_topic_arn
}