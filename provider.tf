terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0" # AWS provider version, not terraform version
    }
  }

  backend "s3" {
    bucket = "prajai-terraform-state"
    key    = "eksctl"
    region = "us-east-1"
    dynamodb_table = "prajai-tf-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}