terraform {
  required_version = ">= 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
      #Will allow installation of 4.15.1 and 4.15.10 but not 4.16.0
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "3.4.2"
    # }
  }
  # add terraform state to bucket. this has to be applied after bucket is created.
  backend "s3" {
    bucket = "terraform-state-s3-bucket-gmt"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

}
