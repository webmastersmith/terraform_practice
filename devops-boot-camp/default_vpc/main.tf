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
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name"    = "My_VPC"
    "managed" = "Terraform"
  }
}



# igw
# egress igw for local

# get cidr from vpc
# route table -public and private routes
resource "aws_route_table" "local_only" {
  vpc_id = aws_default_vpc.default.id

  # public gateway all trafic out
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_default_vpc.default.id

  # public gateway all trafic out
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}
resource "aws_route_table" "example" {
  vpc_id = aws_default_vpc.default.id

  # public gateway all trafic out
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
  }

  tags = {
    Name = "example"
  }
}

# create default subnets a,b,c
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

output "cidr" {
  value = aws_default_vpc.default.cidr_block
}
output "default_vpc_id" {
  value = aws_default_vpc.default.id
}
