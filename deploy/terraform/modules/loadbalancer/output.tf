output "alb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the load balancer"
  value       = aws_lb.this.zone_id
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the load balancer"
  value       = aws_lb.this.arn_suffix
}

output "target_group_id" {
  description = "The ID of the target group"
  value       = aws_lb_target_group.this.id
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "The ARN suffix of the target group"
  value       = aws_lb_target_group.this.arn_suffix
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "The ARN of the HTTPS listener"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

output "dns_record_name" {
  description = "The name of the DNS record"
  value       = var.create_dns_record ? aws_route53_record.this[0].fqdn : null
}