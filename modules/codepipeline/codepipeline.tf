# Local variable used to specify the parameters of cloudformation template 
locals {
  parameter_overrides = jsonencode({
    AccountId = var.current_account_id
  })
}

# Build an AWS S3 bucket for CodePipeline to use as artifact storage
resource "aws_s3_bucket" "codepipeline_artifact_bucket" {
  bucket = var.codepipeline_artifact_bucket_name
}

# These rules are important to use in a CodePipeline to ensure the bucket is only modified by our pipeline/account
resource "aws_s3_bucket_ownership_controls" "codepipeline_artifact_bucket" {
  bucket = aws_s3_bucket.codepipeline_artifact_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_artifact_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_artifact_bucket]

  bucket = aws_s3_bucket.codepipeline_artifact_bucket.id
  acl    = "private"
}

# Output the pipeline artifact bucket back to main.tf
output "codepipeline_artifact_bucket_name" {
  value = var.codepipeline_artifact_bucket_name
}

output "codepipeline_artifact_bucket_arn" {
  value = aws_s3_bucket.codepipeline_artifact_bucket.arn
}

# Create a CodePipeline for the API
resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = var.codepipeline_role_arn

  # Define the S3 bucket created as artifact bucket. 
  # This is used to pass the artifacts built by Build stage into deploy stage.
  artifact_store {
    location = aws_s3_bucket.codepipeline_artifact_bucket.bucket
    type     = "S3"
  }

  # Retrieves the application code from the CodeCommit Repo
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName = var.codecommit_repo_name
        BranchName     = "main"
      }
    }
  }

  # Build the application using buildspec.yml and template.yml
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = var.codebuild_project_test_name
      }
    }
  }

  # Manual approval before deploy stage
  stage {
    name = "Manual_Approval"

    action {
      name     = "Manual-Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }

  # Deploy the application using outputtemplate.yml generated by Build stage.
  stage {
    name = "Deploy"

    # Creates a change set, for updating the existing CloudFormation Stack.
    # If there isn't a Stack deployed yet, it will generate an Add Set. 
    action {
      name            = "CreateChangeSet"
      version         = "1"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      role_arn        = var.codepipeline_role_arn
      input_artifacts = ["build_output"]
      run_order       = 1

      configuration = {
        ActionMode    = "CHANGE_SET_REPLACE"
        StackName     = "Star-Wars-API-Stack"
        ChangeSetName = "Star-Wars-API-Stack-Changes"
        RoleArn       = var.codepipeline_role_arn
        TemplatePath  = "build_output::outputtemplate.yml"
        ParameterOverrides = local.parameter_overrides
      }
    }

    # Deploys the Change Set generated 
    action {
      name             = "DeployChangeSet"
      version          = "1"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CloudFormation"
      output_artifacts = ["cf_artifacts"]
      run_order        = 2

      configuration = {
        ActionMode    = "CHANGE_SET_EXECUTE"
        StackName     = "Star-Wars-API-Stack"
        ChangeSetName = "Star-Wars-API-Stack-Changes"
      }
    }
  }
}