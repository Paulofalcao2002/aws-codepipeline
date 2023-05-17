# Build CodeCommit git repo for our Star Wars API
resource "aws_codecommit_repository" "repo" {
  repository_name = var.repository_name
  description     = "CodeCommit repo for my Star Wars API"
  default_branch  = "main"
}

# Output the repo info back to main.tf
output "terraform_codecommit_repo_arn" {
  value = aws_codecommit_repository.repo.arn
}
output "terraform_codecommit_repo_name" {
  value = var.repository_name
}