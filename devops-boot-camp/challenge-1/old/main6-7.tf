terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
    }
  }
}

# !!Use your own access and secret keys!!
provider "aws" {
  region = "us-east-2"
  # access_key = "AKIA52LJEQNMWCTT53NX"
  # secret_key = "GAqkjt7DUbpIYA8EJZ7XzsI5jdYDsK+Z44OpRS3x"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-example"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name      = "my-gateway"
    "managed" = "Terraform"
  }
}
# 3. Create Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # all trafic not local, send to IGW
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    "Name"    = "my-route-table"
    "managed" = "Terraform"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "tf-example"
  }
}


# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.example.id
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "one" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.100"]
  # security_groups = [
  #   aws_security_group.web_traffic.id,
  #   aws_security_group.github_webhook.id,
  #   aws_security_group.ssh.id
  # ]

  # this can be done in the instance.
  attachment {
    instance     = aws_instance.server[0].id
    device_index = 1
  }
}

resource "aws_network_interface" "two" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["172.16.10.101"]
  # security_groups = [
  #   aws_security_group.web_traffic.id,
  #   aws_security_group.github_webhook.id,
  #   aws_security_group.ssh.id
  # ]

  # this can be done in the instance.
  attachment {
    instance     = aws_instance.server[1].id
    device_index = 1
  }
}

# 8. Assign an elastic IP ot the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.one.id
  associate_with_private_ip = "172.16.10.100"
  depends_on = [
    aws_internet_gateway.gw
  ]
}
resource "aws_eip" "two" {
  vpc                       = true
  network_interface         = aws_network_interface.two.id
  associate_with_private_ip = "172.16.10.101"
  depends_on = [
    aws_internet_gateway.gw
  ]
}




resource "aws_instance" "server" {
  ami           = "ami-0f924dc71d44d23e2"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id
  count         = 2
  # network_interface {
  #   network_interface_id = aws_network_interface.foo.id
  #   device_index         = 0
  # }
}

output "public_ip-1" {
  value = aws_instance.server[0].public_ip
}
output "instance_id-1" {
  value = aws_eip.one.id
}
output "ip-1" {
  value = aws_eip.one.public_ip
}

output "public_ip-2" {
  value = aws_instance.server[1].public_ip
}
output "private_ip-1" {
  value = aws_instance.server[0].private_ip
}
output "private_ip-2" {
  value = aws_instance.server[1].private_ip
}
