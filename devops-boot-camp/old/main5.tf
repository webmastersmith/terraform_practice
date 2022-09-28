terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
}

# Configuring the AWS Provider
# !!Use your own access and secret keys!!
provider "aws" {
  region = "us-east-2"
  # access_key = "AKIA52LJEQNMWCTT53NX"
  # secret_key = "GAqkjt7DUbpIYA8EJZ7XzsI5jdYDsK+Z44OpRS3x"
}


# Creating a new VPC
resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"

  tags = {
    "Name" = "Production VPC"
  }
}


# Creating a subnet in the VPC
resource "aws_subnet" "webapps" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2a"

  tags = {
    "Name" = "Web Applictations Subnet"
  }
}
