provider "aws" {
    region = "us-east-1"
    shared_config_files = ["C:/Users/paulo/.aws/config"]
    shared_credentials_files = ["C:/Users/paulo/.aws/credentials"]
}

## Build an S3 bucket for logging
module "bootstrap" {
  source                              = "./modules/bootstrap"
  s3_logging_bucket_name              = "paulo-codebuild-demo-logging-bucket"
  codebuild_iam_role_name             = "CodeBuildIamRole"
  codebuild_iam_role_policy_name      = "CodeBuildIamRolePolicy"
  terraform_codecommit_repo_arn       = module.codecommit.terraform_codecommit_repo_arn
  codepipeline_artifact_bucket_arn   = module.codepipeline.codepipeline_artifact_bucket_arn
}

## Build a CodeCommit git repo
module "codecommit" {
    source = "./modules/codecommit"
    repository_name = "MyRepo"
}

## Build a test CodeBuild project 
module "codebuild" {
  source                                 = "./modules/codebuild"
  codebuild_project_test_name            = "CodeBuildTestProject"
  s3_logging_bucket_id                   = module.bootstrap.s3_logging_bucket_id
  codebuild_iam_role_arn                 = module.bootstrap.codebuild_iam_role_arn
  s3_logging_bucket                      = module.bootstrap.s3_logging_bucket
}

## Build a CodePipeline
module "codepipeline" {
  source                                 = "./modules/codepipeline"
  codepipeline_name                      = "CodePipeline"
  codepipeline_artifact_bucket_name      = "paulo-codebuild-demo-artifact-bucket-name"
  codepipeline_role_name                 = "CodePipelineIamRole"
  codepipeline_role_policy_name          = "CodePipelineIamRolePolicy"
  terraform_codecommit_repo_name         = module.codecommit.terraform_codecommit_repo_name
  codebuild_project_test_name            = module.codebuild.codebuild_project_test_name
}