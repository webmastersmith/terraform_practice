# eks module
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  # cluster specs
  cluster_name    = local.cluster_name
  cluster_version = "1.22"

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  control_plane_subnet_ids        = module.vpc.private_subnets
  cluster_endpoint_private_access = true

  # cluster_security_group_additional_rules = {
  #   egress_nodes_ephemeral_ports_tcp = {
  #     description                = "To node 1025-65535"
  #     protocol                   = "tcp"
  #     from_port                  = 1025
  #     to_port                    = 65535
  #     type                       = "egress"
  #     source_node_security_group = true
  #   }
  # }

  # node_security_group_additional_rules = {
  #   ingress_self_all = {
  #     description = "Node to node all ports/protocols"
  #     protocol    = "-1"
  #     from_port   = 0
  #     to_port     = 0
  #     type        = "ingress"
  #     self        = true
  #   }
  #   egress_all = {
  #     description      = "Node all egress"
  #     protocol         = "-1"
  #     from_port        = 0
  #     to_port          = 0
  #     type             = "egress"
  #     cidr_blocks      = ["0.0.0.0/0"]
  #     ipv6_cidr_blocks = ["::/0"]
  #   }
  # }


  # attach these sg rules to control plane
  cluster_additional_security_group_ids = [aws_security_group.cluster.id]

  eks_managed_node_groups = {
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      min_size                             = 1
      max_size                             = 1
      desired_size                         = 1
      create_launch_template               = false
      launch_template_name                 = ""
      instance_types                       = ["t3.medium"]
      ami_id                               = "ami-052efd3df9dad4825" # ubuntu 22.04 LTS server optimized for eks.
      node_security_group_additional_rules = [aws_security_group.worker_group_node.id]
      # ami_type               = "AL2_x86_64" # Amazon linux ec2.
      # disk_size              = 50
      # capacity_type          = "SPOT"

      # Remote access key
      remote_access = {
        ec2_ssh_key = aws_key_pair.ssh_access_key.key_name
      }
    }
  }
  # aws-auth configmap
  manage_aws_auth_configmap = true
  # COE provided
  # aws_auth_users = [
  #   {
  #     userarn  = aws_iam_user.eks-user.arn
  #     username = aws_iam_user.eks-user.name
  #     groups   = ["system:masters"]
  #   },
  # ]

  tags = {
    Name      = "${var.user_name}-cluster"
    Terraform = "true"
  }
} # end module eks



# resource "aws_iam_user" "eks-user" {
#   name = "2206-devops-user"

#   tags = {
#     tag-key = "2206-devops-user"
#   }
# }

# resource "aws_iam_user_policy" "eks-iam-user_policy" {
#   name = "2206-devops-eks-access-policy"
#   user = aws_iam_user.eks-user.name

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid    = "2206-devops-user",
#         Effect = "Allow",
#         Action = [
#           "eks:AccessKubernetesApi",
#           "eks:DescribeCluster",
#           "eks:CreateNodegroup",
#           "eks:DeleteNodegroup",
#           "eks:DescribeNodegroup",
#           "eks:DescribeUpdate",
#           "eks:ListNodegroups",
#           "eks:ListTagsForResource",
#           "eks:UpdateClusterConfig",
#           "eks:UpdateNodegroupConfig"
#         ],
#         Resource = "${module.eks.cluster_arn}"
#       }
#     ]
#   })
# }

# resource "aws_iam_access_key" "eks-access-key" {
#   user = aws_iam_user.eks-user.name
# }

resource "aws_key_pair" "ssh_access_key" {
  key_name   = "2206-devops-key"
  public_key = file(".ssh/id_rsa.pub")
}

# output "aws-keys" {
#   value = {
#     access_key = aws_iam_access_key.eks-access-key.id
#     secret_key = aws_iam_access_key.eks-access-key.secret
#   }
#   sensitive = true
# }
