# Security Groups
resource "aws_security_group" "github_webhook" {
  name        = "GitHub Webhook"
  description = "allow your ip and GitHub ip for Jenkins webhook and allow everything outbound"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = [var.my_ip, "192.30.252.0/22", "185.199.108.0/22", "140.82.112.0/20", "143.55.64.0/20"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name"    = "GitHub Webhook for Jenkins"
    "managed" = "Terraform"
  }
}

resource "aws_security_group" "ssh" {
  name        = "SSH Port"
  description = "allow your ip SSH and allow everything outbound"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = [var.my_ip]
  }
  tags = {
    "Name"    = "SSH MyIP"
    "managed" = "Terraform"
  }
}

variable "ingressrules" {
  type    = list(number)
  default = [80, 443]
}
resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "allow your ip and GitHub webhooks for inbound ports and allow everything outbound"
  vpc_id      = aws_vpc.prod-vpc.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name"    = "Web Traffic All IP"
    "managed" = "Terraform"
  }
}
