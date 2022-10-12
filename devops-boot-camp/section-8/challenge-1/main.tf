terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }
  }
  # backend "s3" {
  #   bucket         = "my-s3-bucket-slug"
  #   key            = "terraform/terraform.tfstate"
  #   region         = "us-east-2"
  #   dynamodb_table = "Bryon-Table-swift"
  # }
  # cloud {
  #   organization = "Batch22" # must exist before terraform init
  #   workspaces {
  #     name = "Devops-Production" # name must NOT exist.
  #   }
  # }

}

# Configuring the AWS Provider
# !!Use your own access and secret keys!!
provider "aws" {
  region  = "us-east-2"
  profile = "default"
}


# Creating a new VPC
resource "aws_vpc" "production" {
  cidr_block = "192.168.0.0/16"

  tags = {
    "Name" = "Production VPC"
  }
}


# Creating a subnet in the VPC
resource "aws_subnet" "webapps" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "192.168.0.32/27"
  availability_zone = "us-east-2b"

  tags = {
    "Name" = "Web Applictations Subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "192.168.10.32/27"
  availability_zone = "us-east-2b"

  tags = {
    "Name" = "Web Applictations Subnet"
  }
}


# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "s3:ListBucket",
#       "Resource": "arn:aws:s3:::my-s3-bucket-slug"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "s3:GetObject",
#         "s3:PutObject",
#         "s3:DeleteObject"
#         "dynamodb:GetItem",
#         "dynamodb:PutItem",
#         "dynamodb:DeleteItem"
#       ],
#       "Resource": "arn:aws:s3:::my-s3-bucket-slug/terraform/terraform.tfstate"
#       "Resource": "arn:aws:dynamodb:*:*:table/Bryon-Table-swift"
#     }
#   ]
# }
