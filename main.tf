# Configuring terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS provider configured using AWS CLI credentials files
provider "aws" {
    region = "us-east-1"
}

# Build a CodeCommit git repo for our Star Wars API
module "codecommit" {
    source = "./modules/codecommit"
    repository_name = "StarWarsAPIRepo"
}

module "iam" {
  source                                 = "./modules/iam"
  codebuild_iam_role_name                = "CodeBuildIamRole"
  codebuild_iam_role_policy_name         = "CodeBuildIamRolePolicy"
  s3_logging_bucket_arn                  = module.codebuild.s3_logging_bucket_arn
  codepipeline_artifact_bucket_arn       = module.codepipeline.codepipeline_artifact_bucket_arn
  codecommit_repo_arn                    = module.codecommit.codecommit_repo_arn
  codepipeline_role_name                 = "CodePipelineIamRole"
  codepipeline_role_policy_name          = "CodePipelineIamRolePolicy"
}

# Build a CodeBuild project for building our CloudFormation template
module "codebuild" {
  source                                 = "./modules/codebuild"
  codebuild_project_name                 = "StarWarsAPICodeBuildProject"
  s3_logging_bucket_name                 = "paulo-codebuild-star-wars-api-logging-bucket"
  codebuild_iam_role_arn                 = module.iam.codebuild_iam_role_arn  
  codecommit_repo_arn                    = module.codecommit.codecommit_repo_arn
  codepipeline_artifact_bucket_name      = module.codepipeline.codepipeline_artifact_bucket_name
  codepipeline_artifact_bucket_arn       = module.codepipeline.codepipeline_artifact_bucket_arn
}

# Build a CodePipeline that will orchestrate source, build, approval and deploy stages
module "codepipeline" {
  source                                 = "./modules/codepipeline"
  codepipeline_name                      = "StarWarsAPICodePipeline"
  codepipeline_artifact_bucket_name      = "paulo-codepipeline-star-wars-api-artifact-bucket-name"
  codecommit_repo_name                   = module.codecommit.codecommit_repo_name
  codebuild_project_name                 = module.codebuild.codebuild_project_name
  codepipeline_role_arn                  = module.iam.codepipeline_iam_role_arn
  current_account_id                     = module.iam.current_account_id
}