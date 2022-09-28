terraform {
  required_version = "1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
      #Will allow installation of 4.32.1 and 4.29.10 but not 4.33.0
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# create vpc
resource "aws_vpc" "production" {
  cidr_block = "192.168.0.0/24"

  tags = {
    "Name"    = "Production VPC"
    "managed" = "Terraform"
  }
}

resource "aws_subnet" "webapps" {
  vpc_id     = aws_vpc.production.id
  cidr_block = "192.168.0.0/27"

  tags = {
    "Name"    = "Web Applications Subnet"
    "managed" = "Terraform"
  }
}
