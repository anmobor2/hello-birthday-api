# IAM module - Creates IAM roles and policies for ECS

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name_prefix}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Attach the AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS task role with specific permissions
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.name_prefix}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# Custom policy for task-specific permissions
resource "aws_iam_policy" "task_policy" {
  name        = "${local.name_prefix}-task-policy"
  description = "Policy for ${var.project_name} tasks in ${var.environment} environment"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:CreateLogGroup"
          ]
          Resource = "arn:aws:logs:${var.aws_region}:*:*"
        }
      ],
      var.enable_secretsmanager ? [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = var.secretsmanager_resource_pattern
        }
      ] : [],
      var.additional_task_policies
    )
  })
}

# Attach custom policy to the task role
resource "aws_iam_role_policy_attachment" "task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.task_policy.arn
}

# Attach additional managed policies if specified
resource "aws_iam_role_policy_attachment" "task_additional_policies" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.ecs_task_role.name
  policy_arn = each.value
}