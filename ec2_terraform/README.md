# Terraform AWS EC2 setup with Jenkins, Docker, AWS, Kubectl

## Create ssh key
```bash
mkdir .ssh
ssh-keygen -t rsa -f ./.ssh/id_rsa.pem
```
## Create file 'terraform.tfvars'
```bash
my_ip = "your ip/32"
AWS_ACCESS="your aws access credentials"
AWS_SECRET="your aws secret"
```

## Start Terraform
```bash
terraform init
terraform apply --auto-approve
# To remove
terraform destroy --auto-approve
```

### At the end of the logs, you will be given the ssh login and Jenkins code.