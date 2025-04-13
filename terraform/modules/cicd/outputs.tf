output "pipeline_id" {
  description = "The ID of the CodePipeline"
  value       = aws_codepipeline.pipeline.id
}

output "pipeline_arn" {
  description = "The ARN of the CodePipeline"
  value       = aws_codepipeline.pipeline.arn
}

output "pipeline_name" {
  description = "The name of the CodePipeline"
  value       = aws_codepipeline.pipeline.name
}

output "artifacts_bucket_name" {
  description = "The name of the S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "github_connection_arn" {
  description = "The ARN of the CodeStar connection to GitHub"
  value       = aws_codestarconnections_connection.github.arn
}

output "github_connection_status" {
  description = "The status of the CodeStar connection to GitHub"
  value       = aws_codestarconnections_connection.github.connection_status
}