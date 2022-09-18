# Create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name      = "my-vpc"
    "managed" = "Terraform"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name      = "my-gateway"
    "managed" = "Terraform"
  }
}

# 3. Create Route Table
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # all trafic not local, send to IGW
    gateway_id = aws_internet_gateway.gw.id
  }

  # route {
  #   ipv6_cidr_block = "::/0"
  #   gateway_id      = aws_internet_gateway.gw.id
  # }

  tags = {
    "Name"    = "my-route-table"
    "managed" = "Terraform"
  }
}

# 4. Create Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name      = "my-subnet"
    "managed" = "Terraform"
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.example.id
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "one" {
  subnet_id   = aws_subnet.subnet-1.id
  private_ips = ["10.0.1.50"]
  security_groups = [
    aws_security_group.web_traffic.id,
    aws_security_group.github_webhook.id,
    aws_security_group.ssh.id
  ]

  # this can be done in the instance.
  # attachment {
  #   instance     = aws_instance.ubuntu_server.id
  #   device_index = 1
  # }
}

# 8. Assign an elastic IP ot the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.one.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [
    aws_internet_gateway.gw
  ]
}
