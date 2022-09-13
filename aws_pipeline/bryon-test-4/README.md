# Cognizant Lab Practice

## Steps
- AWS user assigned policy 'AdministratorAccess'
- github credentials created.

## Clone Infra, Lambda
- git clone https://github.com/DevOpsTestLab/infra
- git clone https://github.com/DevOpsTestLab/sample-aws-lambda

### Infra Folder
- Change variables terrafrom.tfvars
  - add Terraform parameter store variables
```bash
# add to infra / main.tf
resource "aws_ssm_parameter" "sonar_token" {
  name  = "SonarQubeToken"
  type  = "String"
  value = var.sonar_token
}
resource "aws_ssm_parameter" "sonar_url" {
  name  = "SonarQubeEndpoint"
  type  = "String"
  value = "https://sonarcloud.io"
}
resource "aws_ssm_parameter" "sonar_org" {
  name  = "SonarQubeOrg"
  type  = "String"
  value = "devopstestlab"
}
```
- codepipeline
  - add 'force_destroy = true' to s3 bucket

Code Build files
- build.yaml
  - infra / modules / codepipeline / templates / build.yaml -cd into lambda

- scan.yaml
  - Sonar setup -copy values
  - change projectKey=NEW-NAME
  - add parameter store vars

- deploy
  - change terraform -terraform -auto-approve
  - move to build stage
    - curl -sSLo install.sh https://install.hclq.sh
    - sh install.sh -d /usr/local/bin/


### Lambda folder
- change Docker file requirement to requirements
- versions.tf  -change s3 bucket to the one made.


# Pipeline teardown
- manually delete
  - items in s3 bucket created for lambda. (if you didn't add 'force_destroy = true' in pipeline)
    - aws s3 rm --recursive s3://BUCKET-NAME
  - role create: dev_lambda_role
  - lambda function
- infra folder
  - terraform destroy -auto-approve
- s3 folder
  - terraform destroy -auto-approve