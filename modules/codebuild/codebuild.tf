# Build an AWS S3 bucket for codebuild logging
resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = var.s3_logging_bucket_name
}

# These rules are important in a CodePipeline to ensure the bucket is owned by the correct AWS account
resource "aws_s3_bucket_ownership_controls" "s3_logging_bucket" {
  bucket = aws_s3_bucket.s3_logging_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_logging_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_logging_bucket]

  bucket = aws_s3_bucket.s3_logging_bucket.id
  acl    = "private"
}

# Output name of S3 logging bucket back to main.tf
output "s3_logging_bucket_id" {
  value = aws_s3_bucket.s3_logging_bucket.id
}

output "s3_logging_bucket" {
  value = aws_s3_bucket.s3_logging_bucket.bucket
}

# Create an IAM role for CodeBuild to assume
resource "aws_iam_role" "codebuild_iam_role" {
  name = var.codebuild_iam_role_name

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "codebuild.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  	})
}

# Output the CodeBuild IAM role
output "codebuild_iam_role_arn" {
  value = aws_iam_role.codebuild_iam_role.arn
}

# Create an IAM role policy for CodeBuild to use implicitly
resource "aws_iam_role_policy" "codebuild_iam_role_policy" {
  name = var.codebuild_iam_role_policy_name
  role = aws_iam_role.codebuild_iam_role.name

  
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_logging_bucket.arn}",
        "${aws_s3_bucket.s3_logging_bucket.arn}/*",
        "${var.codepipeline_artifact_bucket_arn}",
        "${var.codepipeline_artifact_bucket_arn}/*",
        "arn:aws:s3:::codepipeline-us-east-1*",
        "arn:aws:s3:::codepipeline-us-east-1*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:BatchGet*",
        "codecommit:BatchDescribe*",
        "codecommit:Describe*",
        "codecommit:EvaluatePullRequestApprovalRules",
        "codecommit:Get*",
        "codecommit:List*",
        "codecommit:GitPull"
      ],
      "Resource": "${var.terraform_codecommit_repo_arn}"
    },
    {
      "Action": [
          "lambda:GetAlias",
          "lambda:ListVersionsByFunction"
      ],
      "Effect": "Allow",
      "Resource": [
          "*"
      ]
    },
    {
      "Action": [
          "cloudformation:GetTemplate"
      ],
      "Effect": "Allow",
      "Resource": [
          "*"
      ]
    },
    {
      "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
      ],
      "Effect": "Allow",
      "Resource": [
          "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:Get*",
        "iam:List*"
      ],
      "Resource": "${aws_iam_role.codebuild_iam_role.arn}"
    },
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "${aws_iam_role.codebuild_iam_role.arn}"
    }
  ]
}
POLICY
}

# Create a CodeBuild Project for the API
resource "aws_codebuild_project" "codebuild_project" {
  name          = var.codebuild_project_name
  description   = "Star Wars API Codebuild project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_iam_role.arn

  artifacts {
    name                   = var.codebuild_project_name
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.s3_logging_bucket.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    image_pull_credentials_type = "CODEBUILD"
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "ARTIFACT_BUCKET_NAME"
      value = var.codepipeline_artifact_bucket_name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.s3_logging_bucket.id}/${var.codebuild_project_name}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  tags = {
    Terraform = "true"
  }
}

# Output CodeBuild name to main.tf
output "codebuild_project_name" {
  value = var.codebuild_project_name
}