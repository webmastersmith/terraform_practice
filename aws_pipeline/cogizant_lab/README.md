# cognizant_lab

## 5 Steps
## Task 1
Add s3 and store Terraform state into it.
change s3 bucket name 'infra / versions.tf'
add variable 'general_namespace' to ecr / variables.tf file | assigned in the infra / main.tf
add env variable to variables.tf
change values in the infra / terraform.tfvars -because the s3 bucket name was taken.

## Task 2
sample / requirements.txt, un-needed yamll, and missing s on requests module.

build.yaml
  correct docker file location
deploy.yaml
  golang: 1.14
  - go get -u github.com/mattolenik/hclq
  terraform apply -auto-approve
scan.yaml
  add projectKey name
  add parameter store terraform managed.

## Task 3
Dockerfile
  add cmd statement missing, 
  add s to requirements.txt
  Dockerfile add python: 1.1.2 python:3.9  //aws runtime version wrong.

## Task 4
fix s3 bucket name for state in the lambda function
## Task 5
