variable "codebuild_project_test_name" {
  description = "Name for test CodeBuild Project"
}

variable "s3_logging_bucket_id" {
  description = "ID of the S3 bucket for access logging"
}

variable "s3_logging_bucket" {
  description = "Name of the S3 bucket for access logging"
}

variable "codebuild_iam_role_arn" {
  description = "ARN of the CodeBuild IAM role"
}