terraform {
  required_version = "1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
      #Will allow installation of 4.32.1 and 4.29.10 but not 4.33.0
    }
  }
}

provider "aws" {
  region = var.region
}

# get default vpc id
data "aws_vpc" "default" {
  id = "vpc-0a0d025a857ed6f9d"
}

# get subnet to add ec2 in
# data "aws_subnets" "public" {
#   filter {
#     name   = "subnet-id"
#     values = ["subnet-05fcf57343b8d30d2"]
#   }
# }


variable "ingressrules" {
  type    = list(number)
  default = [22, 80]
}
# Security Group
resource "aws_security_group" "web" {
  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["96.45.235.77/32"]
      # cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name"    = "Default Security Group"
    "managed" = "Terraform"
  }
}


# network interface
resource "aws_network_interface" "public" {
  subnet_id       = "subnet-05fcf57343b8d30d2"
  private_ips     = ["10.0.10.100"]
  security_groups = [aws_security_group.web.id]

  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}



resource "aws_instance" "server" {
  # ami           = "ami-0f924dc71d44d23e2"
  ami           = var.my_ami[var.region]
  key_name      = aws_key_pair.ssh_access_key.key_name
  instance_type = var.my_instance[0]
  # count                       = var.my_instance[1]
  # associate_public_ip_address = var.my_instance[2]
  # instance_type = "t2.small"
  # security_groups = [aws_default_security_group.default_sec_group.name]

  network_interface {
    network_interface_id = aws_network_interface.public.id
    device_index         = 0
  }

  tags = {
    "Name"    = "My_Server"
    "managed" = "Terraform"
  }
}


resource "aws_key_pair" "ssh_access_key" {
  key_name   = "./.ssh/id_rsa"
  public_key = file("./.ssh/id_rsa.pem.pub")
}

output "public_ips" {
  value = aws_instance.server[*].public_ip
}
output "private_ips" {
  value = aws_instance.server[*].private_ip
}
