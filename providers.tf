terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration does not support variables.
  # You must hardcode values here or use partial configuration.
  backend "s3" {
    bucket = "massapplyapp"
    key    = "tfState/terraform.tfstate"
    region = "us-east-1"
  }
}

