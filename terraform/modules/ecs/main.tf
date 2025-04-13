# ECS module - Creates ECS cluster, task definition, and service

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CloudWatch Log Group for container logs
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.name_prefix}"
  retention_in_days = 30

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# ECS Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${local.name_prefix}-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = var.environment_variables

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# ECS Service
resource "aws_ecs_service" "this" {
  name            = "${local.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.project_name
      container_port   = var.container_port
    }
  }

  # Deployment configuration for zero-downtime deployments
  deployment_controller {
    type = "ECS"
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  # Prevent Terraform from trying to update the task definition on every apply
  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Auto-scaling for the ECS service
resource "aws_appautoscaling_target" "this" {
  count              = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto-scaling policy based on CPU utilization
resource "aws_appautoscaling_policy" "cpu" {
  count = var.enable_autoscaling ? 1 : 0

  name               = "${local.name_prefix}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_scaling_target
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}