terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"

    }
  }
}

resource "random_pet" "name" {
  length = 1 # how many words, separated by -
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_dynamodb_table" "example" {
  name           = "Bryon-Table-${random_pet.name.id}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Architect = "Bryon"
    Zone      = "Ohio"
  }
}

output "table_arn" {
  value = aws_dynamodb_table.example.arn
}
output "table_id" {
  value = aws_dynamodb_table.example.id
}
