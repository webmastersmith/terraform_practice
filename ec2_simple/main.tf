terraform {
  required_version = ">= 1.2.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
      #Will allow installation of 4.29.1 and 4.29.10 but not 4.30.0
    }
  }

  # backend "s3" {
  #   bucket = "devopstestlab"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {}
