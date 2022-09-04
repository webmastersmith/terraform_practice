terraform {
  required_version = ">= 1.2.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.29.0"
      #Will allow installation of 4.15.1 and 4.15.10 but not 4.16.0
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.2"
    }
  }
  # add state to bucket. this has to be applied after bucket is created.
  backend "s3" {
    bucket = "terraform-state-s3-bucket-njj"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
  numeric = false
  lower   = true
}

locals {
  project_id          = random_string.suffix.result
  env_namespace       = join("_", [var.org_name, var.team_name, local.project_id, var.env["dev"]])
  general_namespace   = join("_", [var.org_name, var.team_name, local.project_id])
  s3_bucket_namespace = join("-", [var.org_name, var.team_name, local.project_id, var.env["dev"]])

}
data "aws_caller_identity" "current" {}
module "codepipeline" {
  source                 = "./modules/codepipeline"
  general_namespace      = local.general_namespace
  env_namespace          = local.env_namespace
  s3_bucket_namespace    = local.s3_bucket_namespace
  codecommit_repo        = module.codecommit.codecommit_configs.repository_name
  codecommit_branch      = module.codecommit.codecommit_configs.default_branch
  codebuild_image        = var.codebuild_image
  codebuild_type         = var.codebuild_type
  codebuild_compute_type = var.codebuild_compute_type
  ecr_repo_arn           = module.ecr.ecr_configs.ecr_repo_arn
  build_args = [
    {
      name  = "REPO_URI"
      value = module.ecr.ecr_configs.ecr_repo_url
    },
    {
      name  = "REPO_ARN"
      value = module.ecr.ecr_configs.ecr_repo_arn
    },
    {
      name  = "TERRAFORM_VERSION"
      value = var.terraform_ver
    },
    {
      name  = "ENV_NAMESPACE"
      value = local.env_namespace
    },
    {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  ]
}

module "codecommit" {
  source            = "./modules/codecommit"
  general_namespace = local.general_namespace
  env_namespace     = local.env_namespace
  codecommit_branch = var.codecommit_branch
}

module "ecr" {
  source            = "./modules/ecr"
  general_namespace = local.general_namespace
  env_namespace     = local.env_namespace
}
