variable "codebuild_project_name" {
  description = "Name for Star Wars API CodeBuild Project"
}

variable "s3_logging_bucket_name" {
  description = "Name of S3 bucket to use for access logging"
}

variable "codebuild_iam_role_arn" {
  description = "Codebuild IAM role ARN"
}

variable "codecommit_repo_arn" {
  description = "Terraform CodeCommit git repo ARN"
}

variable "codepipeline_artifact_bucket_name" {
  description = "CodePiepline artifact bucket name"
}

variable "codepipeline_artifact_bucket_arn" {
  description = "CodePiepline artifact bucket ARN"
}