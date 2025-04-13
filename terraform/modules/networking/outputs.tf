output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "alb_security_group_id" {
  description = "The ID of the security group for the ALB"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "The ID of the security group for the ECS service"
  value       = aws_security_group.ecs_service.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}
