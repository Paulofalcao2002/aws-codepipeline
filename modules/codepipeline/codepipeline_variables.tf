variable "codepipeline_artifact_bucket_name" {
  description = "Name of the CodePipeline S3 bucket for artifacts"
}

variable "codepipeline_role_name" {
  description = "Name of the Star Wars API CodePipeline IAM Role"
}

variable "codepipeline_role_policy_name" {
  description = "Name of the Star Wars API IAM Role Policy"
}

variable "codepipeline_name" {
  description = "Star Wars API CodePipeline Name"
}

variable "terraform_codecommit_repo_name" {
  description = "Star Wars API CodeCommit repo name"
}

variable "codebuild_project_test_name" {
  description = "Star Wars API plan codebuild project name"
}