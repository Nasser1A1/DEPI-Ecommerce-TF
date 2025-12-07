variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for state"
  type        = string
}

variable "s3_bucket_path" {
  description = "Path in S3 bucket for state file"
  type        = string
}

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = []
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}
