terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    backend "s3" {
      bucket = var.s3_bucket_name
      key    = var.s3_bucket_path
      region = var.aws_region
    }
    
  }
}

provider "aws" {
  region = var.aws_region
}
