# CI/CD pipeline module for AWS CodePipeline

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# S3 bucket for pipeline artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name_prefix}-pipeline-artifacts"

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Name = "${local.name_prefix}-pipeline-artifacts"
    }
  )
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CodeBuild role
resource "aws_iam_role" "codebuild" {
  name = "${local.name_prefix}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
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

# CodeBuild policy
resource "aws_iam_policy" "codebuild" {
  name        = "${local.name_prefix}-codebuild-policy"
  description = "Policy used by CodeBuild for ${var.project_name} in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          var.task_execution_role_arn,
          var.task_role_arn
        ]
      }
    ]
  })
}

# Attach policy to CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codebuild.arn
}

# CodePipeline role
resource "aws_iam_role" "codepipeline" {
  name = "${local.name_prefix}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
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

# CodePipeline policy
resource "aws_iam_policy" "codepipeline" {
  name        = "${local.name_prefix}-codepipeline-policy"
  description = "Policy used by CodePipeline for ${var.project_name} in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = aws_codestarconnections_connection.github.arn
      }
    ]
  })
}

# Attach policy to CodePipeline role
resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}

# CodeStar connection for GitHub
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.name_prefix}-github-connection"
  provider_type = "GitHub"

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CodeBuild project for testing
resource "aws_codebuild_project" "test" {
  name          = "${local.name_prefix}-test"
  description   = "Test stage for ${var.project_name} in ${var.environment}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 10

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/test-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.name_prefix}-test"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CodeBuild project for SonarQube analysis
resource "aws_codebuild_project" "sonar" {
  name          = "${local.name_prefix}-sonar"
  description   = "SonarQube analysis for ${var.project_name} in ${var.environment}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 15

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode             = false
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "SONAR_TOKEN"
      value = var.sonar_token
      type  = var.sonar_token == "" ? "PLAINTEXT" : "PARAMETER_STORE"
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/sonar-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.name_prefix}-sonar"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CodeBuild project for Security scanning
resource "aws_codebuild_project" "security" {
  name          = "${local.name_prefix}-security"
  description   = "Security scanning for ${var.project_name} in ${var.environment}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 20

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode             = true  # Required for Docker operations
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = var.ecr_repository_uri
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/security-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.name_prefix}-security"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CodeBuild project for building and pushing the Docker image
resource "aws_codebuild_project" "build" {
  name          = "${local.name_prefix}-build"
  description   = "Build stage for ${var.project_name} in ${var.environment}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 10

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = var.ecr_repository_uri
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/build-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.name_prefix}-build"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CodeBuild project for deploying to ECS
resource "aws_codebuild_project" "deploy" {
  name          = "${local.name_prefix}-deploy"
  description   = "Deploy stage for ${var.project_name} in ${var.environment}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 10

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = var.ecs_cluster_name
    }

    environment_variable {
      name  = "ECS_SERVICE_NAME"
      value = var.ecs_service_name
    }

    environment_variable {
      name  = "TASK_DEFINITION_FAMILY"
      value = "${local.name_prefix}-service" # Should match ECS task definition family
    }

    environment_variable {
      name  = "CONTAINER_NAME"
      value = var.project_name
    }

    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = var.ecr_repository_uri
    }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec/deploy-buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${local.name_prefix}-deploy"
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}

# CodePipeline
resource "aws_codepipeline" "pipeline" {
  name     = "${local.name_prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  # Source stage - Get code from GitHub
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
      }
    }
  }

  # Test stage - Run tests
  stage {
    name = "Test"

    action {
      name             = "Test"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["test_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.test.name
      }
    }
  }

  # SonarQube analysis stage
  stage {
    name = "CodeQuality"

    action {
      name             = "SonarQube"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["sonar_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.sonar.name
      }
    }
  }

  # Security scanning stage
  stage {
    name = "SecurityScan"

    action {
      name             = "Security"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["security_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.security.name
      }
    }
  }

  # Build stage - Build and push Docker image
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  # Approval stage for Production environment
  dynamic "stage" {
    for_each = var.environment == "pro" ? [1] : []
    content {
      name = "Approval"

      action {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"

        configuration = {
          CustomData = "Please review before deploying to production"
          ExternalEntityLink = var.production_approval_url
        }
      }
    }
  }

  # Deploy stage - Deploy to ECS
  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }
  }

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
    }
  )
}