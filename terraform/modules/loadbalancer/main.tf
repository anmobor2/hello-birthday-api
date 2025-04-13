# Load balancer module - Creates ALB, target groups, and listeners

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# Application Load Balancer
resource "aws_lb" "this" {
  name               = "${local.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Name        = "${local.name_prefix}-alb"
    }
  )
}

# Target group for the ALB
resource "aws_lb_target_group" "this" {
  name        = "${local.name_prefix}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    protocol            = "HTTP"
    matcher             = var.health_check_matcher
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Name        = "${local.name_prefix}-tg"
    }
  )
}

# HTTP listener for the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  # If HTTPS is enabled, redirect HTTP to HTTPS
  dynamic "default_action" {
    for_each = var.enable_https ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # If HTTPS is not enabled, forward to target group
  dynamic "default_action" {
    for_each = var.enable_https ? [] : [1]
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.this.arn
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# HTTPS listener for the ALB (if enabled)
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Route 53 DNS record (if enabled)
resource "aws_route53_record" "this" {
  count = var.create_dns_record ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.environment_prefix != "" ? "${var.environment_prefix}${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}