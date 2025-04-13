# Monitoring module - Creates CloudWatch alarms, dashboard, and SNS topics

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  count = var.create_sns_topic ? 1 : 0

  name = "${local.name_prefix}-alerts"

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "alerts" {
  count = var.create_sns_topic ? 1 : 0

  arn    = aws_sns_topic.alerts[0].arn
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.name_prefix}-alerts-policy"
    Statement = [
      {
        Sid    = "DefaultSnsPolicy"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.alerts[0].arn
        Condition = {
          StringEquals = {
            "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Email subscription to the SNS topic
resource "aws_sns_topic_subscription" "email" {
  count = var.create_sns_topic && var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${local.name_prefix}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "This alarm monitors ECS CPU utilization"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Memory utilization alarm
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${local.name_prefix}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "This alarm monitors ECS memory utilization"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# HTTP 5XX errors alarm
resource "aws_cloudwatch_metric_alarm" "http_5xx" {
  count = var.alb_arn_suffix != "" && var.target_group_arn_suffix != "" ? 1 : 0

  alarm_name          = "${local.name_prefix}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This alarm monitors HTTP 5XX errors"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Dashboard for monitoring key metrics
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
            ]
            period = 300
            stat   = "Average"
            region = var.aws_region
            title  = "CPU Utilization"
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 0
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name]
            ]
            period = 300
            stat   = "Average"
            region = var.aws_region
            title  = "Memory Utilization"
          }
        }
      ],
      var.alb_arn_suffix != "" ? [
        {
          type   = "metric"
          x      = 0
          y      = 6
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix]
            ]
            period = 300
            stat   = "Sum"
            region = var.aws_region
            title  = "Request Count"
          }
        },
        {
          type   = "metric"
          x      = 12
          y      = 6
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.alb_arn_suffix],
              ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.alb_arn_suffix],
              ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.alb_arn_suffix]
            ]
            period = 300
            stat   = "Sum"
            region = var.aws_region
            title  = "HTTP Response Codes"
          }
        }
      ] : []
    )
  })
}

# Data source for getting the current account ID
data "aws_caller_identity" "current" {}