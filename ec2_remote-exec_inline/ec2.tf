# data "template_file" "init" {
#   template = file("./install-jenkins.sh")
#   vars = {
#     AWS_ACCESS = var.AWS_ACCESS
#     AWS_SECRET = var.AWS_SECRET
#   }
# }

# resource block
resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.al2.id
  instance_type = "t2.micro"
  # instance_type = "t2.small"
  # security_groups = [aws_security_group.web_traffic.name]
  key_name = aws_key_pair.ssh_access_key.key_name

  # create copies
  # count = 2


  network_interface {
    network_interface_id = aws_network_interface.one.id
    device_index         = 0
  }

  # user_data = data.template_file.init.rendered
  # user_data = file("install-jenkins.sh")

  # you are ec2-user
  provisioner "remote-exec" {
    inline = [
      "sudo yum upgrade -y",
      "sudo yum install -y git",
      "sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install -y jenkins java-11-amazon-corretto",
      "sudo amazon-linux-extras install -y docker",
      "sudo systemctl enable docker.service",
      "sudo usermod -a -G docker jenkins",
      "sudo systemctl enable jenkins",
      "sudo systemctl restart docker.service",
      "sudo systemctl restart jenkins",

      # add aws to /var/lib/jenkins
      "cd /tmp",
      "curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o ./awscliv2.zip",
      "unzip -q ./awscliv2.zip",
      "sudo ./aws/install",

      # create aws credentials file
      "sudo mkdir -p ~jenkins/.aws",
      "echo aws_access_key_id=${var.AWS_ACCESS} | sudo tee ~jenkins/.aws/credentials",
      "echo aws_secret_access_key=${var.AWS_SECRET} | sudo tee -a ~jenkins/.aws/credentials",
      "sudo chown -R jenkins: ~jenkins/.aws",

      # install kubectl
      "curl -o /tmp/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl",
      "chmod +x /tmp/kubectl",
      "sudo mv /tmp/kubectl /usr/bin/kubectl",
      # sudo -i -u jenkins aws eks update-kubeconfig --region $AWS_REGION --name 'your-cluster'

      # get ec2 ip and jenkins password to print to logs
      "echo ssh -i ./.ssh/id_rsa.pem ec2-user@${self.public_ip}",
      "echo Jenkins login: ${self.public_ip}:8080",
      "echo Jenkins code: $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)"
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("./.ssh/id_rsa.pem") # <your keypair name here>
  }

  tags = {
    "Name"    = "Jenkins"
    "managed" = "Terraform"
    # "Name" = "Jenkins_Server${count.index}"

  }
}

resource "aws_key_pair" "ssh_access_key" {
  key_name   = "./.ssh/id_rsa"
  public_key = file("./.ssh/id_rsa.pem.pub")
}

# ec2 logs: /var/log/cloud-init-output.log
