terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
}

# Configure the AWS Provider
# !!Use your own access and secret keys!!
provider "aws" {
  region = var.region
  # access_key = "AKIA52LJEQNMWCTT53NX"
  # secret_key = "GAqkjt7DUbpIYA8EJZ7XzsI5jdYDsK+Z44OpRS3x"
}

# Creating a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Name" = "Production ${var.main_vpc_name}" # string interpolation
  }
}

# Creating a subnet in the VPC
resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet
  availability_zone = var.subnet_zone
  tags = {
    "Name" = "Web subnet"
  }
}

# Creating an Intenet Gateway
resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.main_vpc_name} IGW"
  }
}

#  Associating the IGW to the default RT
resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0" # default route
    gateway_id = aws_internet_gateway.my_web_igw.id
  }
  tags = {
    "Name" = "my-default-rt"
  }
}

variable "ingressrules" {
  type    = list(number)
  default = [22, 80]
}

# Default Security Group
resource "aws_default_security_group" "default_sec_group" {
  vpc_id = aws_vpc.main.id

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
    "Name" = "Default Security Group"
  }
}

resource "aws_network_interface" "one" {
  subnet_id       = aws_subnet.web.id
  private_ips     = ["10.0.100.10"]
  security_groups = [aws_default_security_group.default_sec_group.id]

  # security_groups = [
  #   aws_security_group.web_traffic.id,
  #   aws_security_group.github_webhook.id,
  #   aws_security_group.ssh.id
  # ]

  # this can be done in the instance.
}

resource "aws_eip" "one" {
  vpc               = true
  network_interface = aws_network_interface.one.id
  # associate_with_private_ip = "10.0.100.10"
  depends_on = [
    aws_internet_gateway.my_web_igw
  ]
}

data "aws_ami" "latest_ubuntu_server" {
  owners      = ["099720109477"] # Canonical Account
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-097a2df4ac947655f"]
  }
}



resource "aws_instance" "apache2" {
  # ami           = "ami-0f924dc71d44d23e2"
  ami           = data.aws_ami.latest_ubuntu_server.id
  instance_type = "t2.micro"
  # instance_type = "t2.small"
  # security_groups = [aws_default_security_group.default_sec_group.name]
  key_name = aws_key_pair.ssh_access_key.key_name

  # create copies
  # count = 2

  # Run remote-exec first because will loop till ec2 instance is ready, otherwise local-exec will fail to connect.
  provisioner "remote-exec" {
    script = "./apache2.sh"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("./.ssh/id_rsa.pem") # <your keypair name here>
  }
  provisioner "local-exec" {
    command    = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${aws_key_pair.ssh_access_key.key_name}.pem playbook.yaml"
    on_failure = continue
  }

  network_interface {
    network_interface_id = aws_network_interface.one.id
    device_index         = 0
  }

  tags = {
    "Name"    = "Apache2"
    "managed" = "Terraform"
    # "Name" = "Jenkins_Server${count.index}"

  }
}


resource "aws_key_pair" "ssh_access_key" {
  key_name   = "./.ssh/id_rsa"
  public_key = file("./.ssh/id_rsa.pem.pub")
}


output "public_ip" {
  value = aws_instance.apache2.public_ip
}
output "private_ip" {
  value = aws_instance.apache2.private_ip
}

output "ami" {
  value = data.aws_ami.latest_ubuntu_server.id
}
output "ami-name" {
  value = data.aws_ami.latest_ubuntu_server.name
}
