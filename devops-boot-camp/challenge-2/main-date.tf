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

locals {
  time = timestamp()
}

output "current_time" {
  value = local.time
}
output "cool_time" {
  value = formatdate("MMMM MM YYYY hh:mm:ss ZZZ", local.time)
}
