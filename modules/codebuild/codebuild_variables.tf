variable "codebuild_project_name" {
  description = "Name for test CodeBuild Project"
}

variable "s3_logging_bucket_name" {
  description = "Name of S3 bucket to use for access logging"
}

variable "codebuild_iam_role_name" {
  description = "Name for IAM Role utilized by CodeBuild"
}

variable "codebuild_iam_role_policy_name" {
  description = "Name for IAM policy used by CodeBuild"
}

variable "terraform_codecommit_repo_arn" {
  description = "Terraform CodeCommit git repo ARN"
}

variable "codepipeline_artifact_bucket_arn" {
  description = "CodePiepline artifact bucket ARN"
}