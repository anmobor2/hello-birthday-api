# Network module - Creates VPC, subnets, and security groups

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# VPC configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Security group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow inbound traffic to the ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add HTTPS if TLS is enabled
  dynamic "ingress" {
    for_each = var.enable_https ? [1] : []
    content {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Name        = "${local.name_prefix}-alb-sg"
    }
  )
}

# Security group for the ECS service
resource "aws_security_group" "ecs_service" {
  name        = "${local.name_prefix}-ecs-service-sg"
  description = "Allow inbound traffic to the ECS service"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Name        = "${local.name_prefix}-ecs-service-sg"
    }
  )
}
