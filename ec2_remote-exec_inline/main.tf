
terraform {
  # backend "s3" {
  #   bucket = "devopstestlab"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }

}

provider "aws" {
  region = "us-east-1"
}

# Data Block
data "aws_ami" "al2" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}
