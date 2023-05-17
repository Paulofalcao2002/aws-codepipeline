# AWS provider configured using AWS CLI credentials files
provider "aws" {
    region = "us-east-1"
    shared_config_files = ["C:/Users/paulo/.aws/config"]
    shared_credentials_files = ["C:/Users/paulo/.aws/credentials"]
}

# Build a CodeCommit git repo for our Star Wars API
module "codecommit" {
    source = "./modules/codecommit"
    repository_name = "StarWarsAPIRepo"
}

# Build a CodeBuild project for building our CloudFormation template
module "codebuild" {
  source                                 = "./modules/codebuild"
  codebuild_project_name                 = "StarWarsAPICodeBuildProject"
  s3_logging_bucket_name                 = "paulo-codebuild-star-wars-api-logging-bucket"
  codebuild_iam_role_name                = "CodeBuildIamRole"
  codebuild_iam_role_policy_name         = "CodeBuildIamRolePolicy"
  terraform_codecommit_repo_arn          = module.codecommit.terraform_codecommit_repo_arn
  codepipeline_artifact_bucket_arn       = module.codepipeline.codepipeline_artifact_bucket_arn
}

# Build a CodePipeline that will orchestrate source, build, approval and deploy stages
module "codepipeline" {
  source                                 = "./modules/codepipeline"
  codepipeline_name                      = "StarWarsAPICodePipeline"
  codepipeline_artifact_bucket_name      = "paulo-codebuild-demo-artifact-bucket-name"
  codepipeline_role_name                 = "CodePipelineIamRole"
  codepipeline_role_policy_name          = "CodePipelineIamRolePolicy"
  terraform_codecommit_repo_name         = module.codecommit.terraform_codecommit_repo_name
  codebuild_project_test_name            = module.codebuild.codebuild_project_name
}