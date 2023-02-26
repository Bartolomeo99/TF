terraform {
    backend "s3" {
    bucket         = "<name_of_bucket>"
    key            = "another-path/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "<name_of_table"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "template" {
  # Configuration options
}
