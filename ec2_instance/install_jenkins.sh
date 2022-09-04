#!/usr/bin/bash
sudo yum update –y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo amazon-linux-extras install java-openjdk11 -y
sudo yum install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
# sudo systemctl status jenkins
# sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# sudo amazon-linux-extras install -y docker
# sudo systemctl enable docker.service
# sudo usermod -a -G docker jenkins
# sudo systemctl restart docker.service

# https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/