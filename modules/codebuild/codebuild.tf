# Create a test CodeBuild Project
resource "aws_codebuild_project" "codebuild_project_test" {
  name          = var.codebuild_project_test_name
  description   = "Terraform codebuild project"
  build_timeout = "5"
  service_role  = var.codebuild_iam_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = var.s3_logging_bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${var.s3_logging_bucket_id}/${var.codebuild_project_test_name}/build-log"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec_terraform_plan.yml"
  }

  tags = {
    Terraform = "true"
  }
}

# Output TF Plan CodeBuild name to main.tf
output "codebuild_test_name" {
  value = var.codebuild_project_test_name
}