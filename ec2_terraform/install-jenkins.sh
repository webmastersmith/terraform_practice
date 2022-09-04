#!/usr/bin/bash
# sudo tail -f /var/log/cloud-init-output.log  //ec2 logs: 
# this script is run by root
# https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/
sudo yum upgrade -y
sudo yum install -y curl git
sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install -y jenkins java-11-amazon-corretto
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker.service
sudo usermod -a -G docker jenkins
sudo systemctl enable jenkins
sudo systemctl restart docker.service
sudo systemctl restart jenkins

# add aws to /var/lib/jenkins
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ./awscliv2.zip
unzip -qq ./awscliv2.zip
./aws/install

# become jenkins
# create credentials file
sudo mkdir -p ~jenkins/.aws
sudo tee ~jenkins/.aws/credentials <<EOF
aws_access_key_id="${AWS_ACCESS}"
aws_secret_access_key="${AWS_SECRET}"
EOF
chown -R jenkins: ~jenkins/.aws

# install kubectl
curl -o /tmp/kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.7/2022-06-29/bin/linux/amd64/kubectl
chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/bin/kubectl
# sudo -i -u jenkins aws eks update-kubeconfig --region $AWS_REGION --name 'bryon-cluster'


# get ec2 ip and jenkins password to print to logs
echo "$(curl https://checkip.amazonaws.com)"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
