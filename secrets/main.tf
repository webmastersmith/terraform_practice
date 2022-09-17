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
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
  lower   = true
}

# create secret name
resource "aws_secretsmanager_secret" "sonarcloud" {
  name = "example_secret-${random_string.suffix.result}"
  tags = {
    "managed" : "Terraform"
  }
}

# create secret value
resource "aws_secretsmanager_secret_version" "value" {
  secret_id     = aws_secretsmanager_secret.sonarcloud.id
  secret_string = "example-string-to-protect!$%^"
}


# outputs
output "secret_arn" {
  value = aws_secretsmanager_secret.sonarcloud.id
}

# # secret must be created first.
# data "aws_secretsmanager_secret_version" "secret-version" {
#   secret_id = aws_secretsmanager_secret.sonarcloud.id
# }
# # this will not print secret, to view secret: terraform output -json
# output "secret_string" {
#   value     = data.aws_secretsmanager_secret_version.secret-version.secret_string
#   sensitive = true
# }
