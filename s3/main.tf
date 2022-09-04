terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.2"
    }

  }
  # terriform version
  required_version = "~> 1.2.8"

  # add state to bucket. this has to be applied after bucket is created.
  # backend "s3" {
  #   bucket = "terra-ptkgux"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }

}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  number  = false
  lower   = true
}


provider "aws" {}
locals {
  s3_name = "terraform-state-${random_string.suffix.result}"
}
# data "aws_s3_bucket" "selected" {
#   bucket = local.s3_name
# }

resource "aws_s3_bucket" "terraform-state" {
  bucket = local.s3_name
}

resource "aws_s3_bucket_acl" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}


# get key arn
data "aws_kms_alias" "s3" {
  name = "alias/terraform_state_key"
}
# encrypt data with key
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = data.aws_kms_alias.s3.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
