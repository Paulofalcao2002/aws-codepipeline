variable "codebuild_iam_role_name" {
  description = "Name for IAM Role utilized by CodeBuild"
}

variable "codebuild_iam_role_policy_name" {
  description = "Name for IAM policy used by CodeBuild"
}

variable "s3_logging_bucket_arn" {
  description = "ARN of CodeBuild logging bucket"
}

variable "codepipeline_artifact_bucket_arn" {
  description = "ARN of CodePipeline artifact bucket"
}

variable "codecommit_repo_arn" {
  description = "ARN of CodeCommit repo"
}

variable "codepipeline_role_name" {
  description = "Name of the Star Wars API CodePipeline IAM Role"
}

variable "codepipeline_role_policy_name" {
  description = "Name of the Star Wars API IAM Role Policy"
}