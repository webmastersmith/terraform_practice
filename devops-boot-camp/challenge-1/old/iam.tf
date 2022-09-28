terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

variable "users" {
  type    = list(string)
  default = ["test10", "test20", "test30"]
}
resource "aws_iam_user" "test" {
  for_each = toset(var.users)
  name     = each.key
}
