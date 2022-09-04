# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl
# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "${local.cluster_name}-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  manage_default_route_table = true
  default_route_table_tags   = { Name = "default-route-table" }

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  vpc_tags = {
    Name = "${var.user_name}-vpc"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

# data "aws_security_group" "default" {
#   name   = "${local.cluster_name}-vpc"
#   vpc_id = module.vpc.vpc_id
# }



# # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest/submodules/vpc-endpoints
# module "endpoints" {
#   source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

#   vpc_id             = module.vpc.vpc_id
#   security_group_ids = [data.aws_security_group.default.id]

#   endpoints = {
#     ec2 = {
#       service             = "ec2"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       security_group_ids  = [data.aws_security_group.default.id]
#     }
#   }

#   tags = {
#     Name = "ec2-endpoints"
#   }
# }
