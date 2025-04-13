output "task_execution_role_arn" {
  description = "The ARN of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_execution_role_name" {
  description = "The name of the task execution role"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "task_role_arn" {
  description = "The ARN of the task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "task_role_name" {
  description = "The name of the task role"
  value       = aws_iam_role.ecs_task_role.name
}

output "task_policy_arn" {
  description = "The ARN of the task policy"
  value       = aws_iam_policy.task_policy.arn
}

output "task_policy_name" {
  description = "The name of the task policy"
  value       = aws_iam_policy.task_policy.name
}