# # worker group 1
# resource "aws_security_group" "worker_group_node" {
#   name_prefix = "worker_node_sg"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#       var.my_home_ip
#     ]
#   }
# }

# # worker group 2
# resource "aws_security_group" "all_sg" {
#   name_prefix = "all_nodes_sg"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#       "172.16.0.0/12",
#       "192.168.0.0/16"
#     ]
#   }
# }

variable "ingressrules" {
  type    = list(number)
  default = [8080, 80, 22]
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "worker_group_node" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = [var.my_home_ip, "192.30.252.0/22", "185.199.108.0/22", "140.82.112.0/20", "143.55.64.0/20"]
      # github webhooks ip's
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-sg"
  }
}


variable "global-ingressrules" {
  type    = list(number)
  default = [22]
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "cluster" {
  name        = "Allow cluster traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  vpc_id      = module.vpc.vpc_id
  dynamic "ingress" {
    iterator = port
    for_each = var.global-ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = [var.my_home_ip]
      # github webhooks ip's
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-sg"
  }
}
