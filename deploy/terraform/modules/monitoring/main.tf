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

  alarm_name          = "${local.name_prefix}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This alarm monitors HTTP 5XX errors"

  # Use the conditional for alarm_actions instead of count
  alarm_actions       = var.create_sns_topic && var.alb_arn_suffix != "" ? [aws_sns_topic.alerts[0].arn] : []
  ok_actions          = var.create_sns_topic && var.alb_arn_suffix != "" ? [aws_sns_topic.alerts[0].arn] : []

  # Only create dimensions if the ARNs are provided
  dimensions = var.alb_arn_suffix != "" && var.target_group_arn_suffix != "" ? {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  } : {}

  # Add this to prevent errors when dimensions are empty
  count = var.enable_alb_alarm ? 1 : 0

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

# Grafana workspace
resource "aws_grafana_workspace" "this" {
  count = var.enable_grafana ? 1 : 0

  name                     = "${local.name_prefix}-grafana"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["CLOUDWATCH"]

  role_arn = aws_iam_role.grafana[0].arn

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# IAM role para Grafana
resource "aws_iam_role" "grafana" {
  count = var.enable_grafana ? 1 : 0

  name = "${local.name_prefix}-grafana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "grafana.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch" {
  count = var.enable_grafana ? 1 : 0

  role       = aws_iam_role.grafana[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCloudWatchReadOnlyAccess"
}

resource "grafana_dashboard" "hello_api" {
  count = var.enable_grafana ? 1 : 0

  config_json = jsonencode({
    "annotations": {
      "list": []
    },
    "editable": true,
    "graphTooltip": 0,
    "links": [],
    "panels": [
      {
        "datasource": "CloudWatch",
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 30,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "lineInterpolation": "smooth",
              "lineWidth": 2,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "never",
              "spanNulls": true
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            },
            "unit": "percent"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 0
        },
        "options": {
          "legend": {
            "calcs": ["mean", "max"],
            "displayMode": "table",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "multi",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": "CloudWatch",
            "dimensions": {
              "ClusterName": "${var.ecs_cluster_name}",
              "ServiceName": "${var.ecs_service_name}"
            },
            "metricName": "CPUUtilization",
            "namespace": "AWS/ECS",
            "period": "",
            "refId": "A",
            "statistic": "Average"
          }
        ],
        "title": "ECS CPU Utilization",
        "type": "timeseries"
      },
      {
        "datasource": "CloudWatch",
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "line",
              "fillOpacity": 30,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "lineInterpolation": "smooth",
              "lineWidth": 2,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "never",
              "spanNulls": true
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                },
                {
                  "color": "red",
                  "value": 80
                }
              ]
            },
            "unit": "percent"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 0
        },
        "options": {
          "legend": {
            "calcs": ["mean", "max"],
            "displayMode": "table",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "multi",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": "CloudWatch",
            "dimensions": {
              "ClusterName": "${var.ecs_cluster_name}",
              "ServiceName": "${var.ecs_service_name}"
            },
            "metricName": "MemoryUtilization",
            "namespace": "AWS/ECS",
            "period": "",
            "refId": "A",
            "statistic": "Average"
          }
        ],
        "title": "ECS Memory Utilization",
        "type": "timeseries"
      },
      {
        "datasource": "CloudWatch",
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "bars",
              "fillOpacity": 30,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "never",
              "spanNulls": true
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                }
              ]
            },
            "unit": "reqps"
          },
          "overrides": []
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 0,
          "y": 8
        },
        "options": {
          "legend": {
            "calcs": ["sum", "max"],
            "displayMode": "table",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "multi",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": "CloudWatch",
            "dimensions": {
              "LoadBalancer": "${var.alb_arn_suffix}"
            },
            "metricName": "RequestCount",
            "namespace": "AWS/ApplicationELB",
            "period": "",
            "refId": "A",
            "statistic": "Sum"
          }
        ],
        "title": "Request Count",
        "type": "timeseries"
      },
      {
        "datasource": "CloudWatch",
        "fieldConfig": {
          "defaults": {
            "color": {
              "mode": "palette-classic"
            },
            "custom": {
              "axisCenteredZero": false,
              "axisColorMode": "text",
              "axisLabel": "",
              "axisPlacement": "auto",
              "barAlignment": 0,
              "drawStyle": "bars",
              "fillOpacity": 30,
              "gradientMode": "none",
              "hideFrom": {
                "legend": false,
                "tooltip": false,
                "viz": false
              },
              "lineInterpolation": "linear",
              "lineWidth": 1,
              "pointSize": 5,
              "scaleDistribution": {
                "type": "linear"
              },
              "showPoints": "never",
              "spanNulls": true
            },
            "mappings": [],
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {
                  "color": "green",
                  "value": null
                }
              ]
            },
            "unit": "none"
          },
          "overrides": [
            {
              "matcher": {
                "id": "byName",
                "options": "HTTPCode_Target_2XX_Count"
              },
              "properties": [
                {
                  "id": "color",
                  "value": {
                    "fixedColor": "green",
                    "mode": "fixed"
                  }
                }
              ]
            },
            {
              "matcher": {
                "id": "byName",
                "options": "HTTPCode_Target_4XX_Count"
              },
              "properties": [
                {
                  "id": "color",
                  "value": {
                    "fixedColor": "orange",
                    "mode": "fixed"
                  }
                }
              ]
            },
            {
              "matcher": {
                "id": "byName",
                "options": "HTTPCode_Target_5XX_Count"
              },
              "properties": [
                {
                  "id": "color",
                  "value": {
                    "fixedColor": "red",
                    "mode": "fixed"
                  }
                }
              ]
            }
          ]
        },
        "gridPos": {
          "h": 8,
          "w": 12,
          "x": 12,
          "y": 8
        },
        "options": {
          "legend": {
            "calcs": ["sum"],
            "displayMode": "table",
            "placement": "bottom",
            "showLegend": true
          },
          "tooltip": {
            "mode": "multi",
            "sort": "none"
          }
        },
        "targets": [
          {
            "datasource": "CloudWatch",
            "dimensions": {
              "LoadBalancer": "${var.alb_arn_suffix}"
            },
            "metricName": "HTTPCode_Target_2XX_Count",
            "namespace": "AWS/ApplicationELB",
            "period": "",
            "refId": "A",
            "statistic": "Sum"
          },
          {
            "datasource": "CloudWatch",
            "dimensions": {
              "LoadBalancer": "${var.alb_arn_suffix}"
            },
            "metricName": "HTTPCode_Target_4XX_Count",
            "namespace": "AWS/ApplicationELB",
            "period": "",
            "refId": "B",
            "statistic": "Sum"
          },
          {
            "datasource": "CloudWatch",
            "dimensions": {
              "LoadBalancer": "${var.alb_arn_suffix}"
            },
            "metricName": "HTTPCode_Target_5XX_Count",
            "namespace": "AWS/ApplicationELB",
            "period": "",
            "refId": "C",
            "statistic": "Sum"
          }
        ],
        "title": "HTTP Response Codes",
        "type": "timeseries"
      }
    ],
    "refresh": "10s",
    "schemaVersion": 36,
    "style": "dark",
    "tags": [
      "hello-api",
      "ecs",
      "${var.environment}"
    ],
    "templating": {
      "list": []
    },
    "time": {
      "from": "now-3h",
      "to": "now"
    },
    "timepicker": {},
    "timezone": "",
    "title": "Hello API Dashboard",
    "uid": "hello-api-${var.environment}",
    "version": 1
  })

  overwrite = true
}

# Data source for getting the current account ID
data "aws_caller_identity" "current" {}