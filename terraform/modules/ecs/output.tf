output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the task definition"
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_service_id" {
  description = "The ID of the ECS service"
  value       = aws_ecs_service.this.id
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.this.name
}