terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
      #Will allow installation of 4.29.1 and 4.29.10 but not 4.30.0
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  # add terraform state to bucket. this has to be applied after bucket is created.
  # backend "s3" {
  #   bucket = "terra-ptkgux"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = "us-east-2"
}

# create random string
resource "random_pet" "name" {
  length = 1 # how many words, separated by -
}

# create aws bucket name with random string for uniqueness
locals {
  s3_name = "my-s3-bucket-${random_pet.name.id}"
}

# create bucket
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = local.s3_name
  # allow terraform to destroy bucket with contents
  force_destroy = true

  # object_lock_enabled = true
}

# block all objects from being public
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# inform Access Control List bucket is private
resource "aws_s3_bucket_acl" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  acl    = "private"
}

# ## versioning
# resource "aws_s3_bucket_versioning" "versioning_terraform-state" {
#   bucket = aws_s3_bucket.terraform-state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# ## This if for encrypting bucket contents. Must have an KMS key already made.
# ## get arn
# data "aws_kms_alias" "s3" {
#   name = "alias/CHANGE-ME-TO-YOUR-KMS-KEY-NAME"
# }

# ## encrypt data with key
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform-state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = data.aws_kms_alias.s3.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }
# ## End bucket encryption

output "bucket_name" {
  value = aws_s3_bucket.terraform-state.id
}
output "bucket_domain_name" {
  value = "https://${aws_s3_bucket.terraform-state.bucket_domain_name}"
}
