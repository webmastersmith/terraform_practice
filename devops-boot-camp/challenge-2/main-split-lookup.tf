terraform {
  # required_version = "1.3.0"
  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = "~> 4.32.0"
  #     #Will allow installation of 4.32.1 and 4.29.10 but not 4.33.0
  #   }
  # }
}

# provider "aws" {
#   region = var.region
# }

variable "environment" {
  type = map(string)
  default = {
    "test"       = "us-west-1"
    "production" = "us-west-2"
  }
}
variable "availability_zones" {
  type = map(string)
  default = {
    "us-west-1" = "us-west-1a,us-west-1b,us-west-1c"
    "us-west-2" = "us-west-2a,us-west-2b,us-west-2c"
  }
}

output "az" {
  value = element(split(",", var.availability_zones[var.environment["production"]]), 2)
}
output "ZA" {
  value = element(split(",", lookup(var.availability_zones, var.environment.production)), 2)
}
