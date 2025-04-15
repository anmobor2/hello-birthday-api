output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].arn : null
}

output "cpu_alarm_arn" {
  description = "The ARN of the CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "memory_alarm_arn" {
  description = "The ARN of the memory utilization alarm"
  value       = aws_cloudwatch_metric_alarm.memory_high.arn
}

output "http_5xx_alarm_arn" {
  description = "The ARN of the HTTP 5XX error alarm"
  value       = var.alb_arn_suffix != "" && var.target_group_arn_suffix != "" ? aws_cloudwatch_metric_alarm.http_5xx[0].arn : null
}

output "dashboard_name" {
  description = "The name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "grafana_workspace_id" {
  description = "The ID of the Grafana workspace"
  value       = var.enable_grafana ? aws_grafana_workspace.this[0].id : null
}

output "grafana_endpoint" {
  description = "The endpoint URL of the Grafana workspace"
  value       = var.enable_grafana ? aws_grafana_workspace.this[0].endpoint : null
}