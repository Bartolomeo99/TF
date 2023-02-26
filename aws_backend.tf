//Remote backend provides: Sensitive data encrypted
//Collaboration possible
//automation
// TF CLOUD


terraform {
  
  # backend "s3" {
  #   bucket = "Bart-bucket-for-tf-state"
  #   key = "path/terraform.tfstate"
  #   region = "eu-east-1"
  #   dynamodb_table = "tf-state-remote-data"
  #   encrypt = true

  # }
  

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-east-1"

}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "Bart-bucket-for-tf-state"
  force_destroy = true
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule{
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
  }  
}

resource "aws_dynamodb_table" "terraform_data" {
  name = "tf-state-remote-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  
}





# resource "aws_s3_bucket" "terraform_state" {
#   bucket        = "devops-directive-tf-state" # REPLACE WITH YOUR BUCKET NAME
#   force_destroy = true
# }

# resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
#   bucket        = aws_s3_bucket.terraform_state.bucket 
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }