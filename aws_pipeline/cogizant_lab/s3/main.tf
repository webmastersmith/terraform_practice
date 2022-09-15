terraform {
  required_version = ">= 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
      #Will allow installation of 4.29.1 and 4.29.10 but not 4.30.0
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.2"
    }
  }

  # add terraform state to bucket. this has to be applied after bucket is created.
  # backend "s3" {
  #   bucket = "terra-ptkgux"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# create random string
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
  lower   = true
}

# create aws bucket name with random string for uniqueness
locals {
  s3_name = "terraform-state-s3-bucket-${random_string.suffix.result}"
}
# create bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = local.s3_name
  # allow terraform to destroy bucket without having to delete contents
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

# versioning
# resource "aws_s3_bucket_versioning" "versioning_terraform-state" {
#   bucket = aws_s3_bucket.terraform-state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# ## This if for encrypting bucket contents. Must have an KMS key already made.
# get arn
# data "aws_kms_alias" "s3" {
#   name = "alias/CHANGE-ME-TO-YOUR-KMS-KEY-NAME"
# }

# encrypt data with key
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

output "bucket_domain_name" {
  value = aws_s3_bucket.terraform-state.bucket_domain_name
}
