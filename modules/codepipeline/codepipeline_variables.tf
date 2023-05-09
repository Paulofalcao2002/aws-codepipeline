variable "codepipeline_artifact_bucket_name" {
  description = "Name of the CodePipeline S3 bucket for artifacts"
}

variable "codepipeline_role_name" {
  description = "Name of the Terraform CodePipeline IAM Role"
}

variable "codepipeline_role_policy_name" {
  description = "Name of the Terraform IAM Role Policy"
}

variable "codepipeline_name" {
  description = "Terraform CodePipeline Name"
}

variable "terraform_codecommit_repo_name" {
  description = "Terraform CodeCommit repo name"
}

variable "codebuild_project_test_name" {
  description = "Terraform plan codebuild project name"
}