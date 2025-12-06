variable "ecr_repos" {
  type        = list(string)
  description = "List of ECR repository names to create"
  default     = [var.ecr_repositories]
}


resource "aws_ecr_repository" "repos" {
  for_each = toset(var.ecr_repos)

  name = each.value

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}



####################################
# ECR Repository Policy (Optional)
# Allows IAM users in the same account to push/pull
####################################
resource "aws_ecr_repository_policy" "repo_policy" {
  for_each = aws_ecr_repository.repos

  repository = each.value.name

  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid    = "AllowPushPull"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  })
}

