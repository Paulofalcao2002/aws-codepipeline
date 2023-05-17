# Build an AWS S3 bucket for codebuild logging
resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = var.s3_logging_bucket_name
}

# These rules are important in a CodePipeline to ensure the bucket is owned by the correct AWS account
resource "aws_s3_bucket_ownership_controls" "s3_logging_bucket" {
  bucket = aws_s3_bucket.s3_logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_logging_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_logging_bucket]

  bucket = aws_s3_bucket.s3_logging_bucket.id
  acl    = "private"
}

# Output name of S3 logging bucket back to main.tf
output "s3_logging_bucket_id" {
  value = aws_s3_bucket.s3_logging_bucket.id
}

output "s3_logging_bucket" {
  value = aws_s3_bucket.s3_logging_bucket.bucket
}

output "s3_logging_bucket_arn" {
  value = aws_s3_bucket.s3_logging_bucket.arn
}

# Create a CodeBuild Project for the API
resource "aws_codebuild_project" "codebuild_project" {
  name          = var.codebuild_project_name
  description   = "Star Wars API Codebuild project"
  build_timeout = "5"
  service_role  = var.codebuild_iam_role_arn

  artifacts {
    name                   = var.codebuild_project_name
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.s3_logging_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "ARTIFACT_BUCKET_NAME"
      value = var.codepipeline_artifact_bucket_name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.s3_logging_bucket.id}/${var.codebuild_project_name}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  tags = {
    Terraform = "true"
  }
}

# Output CodeBuild name to main.tf
output "codebuild_project_name" {
  value = var.codebuild_project_name
}