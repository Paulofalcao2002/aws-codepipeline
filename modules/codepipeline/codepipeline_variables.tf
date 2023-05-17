variable "codepipeline_artifact_bucket_name" {
  description = "Name of the CodePipeline S3 bucket for artifacts"
}
variable "codepipeline_name" {
  description = "Star Wars API CodePipeline Name"
}

variable "codecommit_repo_name" {
  description = "Star Wars API CodeCommit repo name"
}

variable "codebuild_project_test_name" {
  description = "Star Wars API plan codebuild project name"
}

variable "codepipeline_role_arn" {
  description = "CodePipeline role ARN"
}

variable "current_account_id" {
  description = "Current AWS account id"
}