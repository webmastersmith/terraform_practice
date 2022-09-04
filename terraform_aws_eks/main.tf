terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
  # terriform version
  required_version = "~> 1.2.0"

  # add state to bucket
  # backend "s3" {
  #   bucket = "mybucket"
  #   key    = "path/to/my/key"
  #   region = "us-east-1"
  # }

}


data "aws_eks_cluster" "default" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "default" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

# removed helm. install helm after terraform sets up cluster
# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
#       command     = "aws"
#     }
#   }
# }

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  # cluster_name = "${var.user_name}-cluster-${random_string.suffix.result}" # random ensures no cluster repeats.
  cluster_name = "${var.user_name}-cluster"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
}
