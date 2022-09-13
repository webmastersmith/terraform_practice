# Cognizant Lab Practice

## Steps
- AWS user assigned policy `AdministratorAccess`
  - github credentials created. (These are attached to user and don't need to be re-made every time.)

## Clone Infra, Lambda
- git clone [https://github.com/DevOpsTestLab/infra](https://github.com/DevOpsTestLab/infra)
- git clone [https://github.com/DevOpsTestLab/sample-aws-lambda](https://github.com/DevOpsTestLab/sample-aws-lambda)

### Infra Folder
- Add Terraform parameter store variables to `infra / main.tf`
```sh
# add to end of infra / main.tf
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
  value = "CHANGE-ME-TO-YOUR-ORGANIZATION-NAME"
}
```
- add sonarcloud token variable to `infra / variable.tf`
```sh
variable "sonar_token" {
  description = "SonarCloud token"
  type        = string
}
```
- add sonarcloud token secret and name variables to `infra / terraform.tfvars`
```sh
# org_name   = "CHANGE-ME"
# team_name  = "CHANGE-ME"
# project_id = "CHANGE-ME"
# region     = "us-east-1"

sonar_token = "g4e................py"
```
- `infra / modules / codepipeline / main.tf`
  - add `force_destroy = true` to s3 bucket
```sh
#resource "aws_s3_bucket" "codepipeline_bucket" {
#  bucket        = "${var.s3_bucket_namespace}-codepipeline-bucket"
  force_destroy = true
#}

```
#### Code Build files `infra / modules / codepipeline / templates`
1. `buildspec_build.yaml`
```sh
# line 16
- docker build -t $IMAGE_URI ./lambda
```
2. `buildspec_deploy.yaml`
  - move hclq commands into build stage & add -auto-approve to terraform apply
```sh
# move these from runtime-versions to build stage
- curl -sSLo install.sh https://install.hclq.sh
- sh install.sh -d /usr/local/bin/

# add -auto-approve line 27
terraform apply -auto-approve
```
3. `buildspec_scan.yaml`
```sh
- sonar-scanner -Dsonar.projectKey=sample-lambda-1 -Dsonar.sources=. -Dsonar.login=${SONARQUBE_TOKEN} -Dsonar.organization=${SONAR_ORG} -Dsonar.host.url=${SONARQUBE_ENDPOINT}
```


##  sample-aws-lambda folder
- `sample-aws-lambda / lambda / main.tf`
  - change Docker file requirement.txt to requirements.txt
```sh
RUN pip3 install --no-cache-dir -r requirements.txt
```
- `sample-aws-lambda / versions.tf`
  -comment out the s3 bucket until pipeline is created.
```sh
terraform {
  # backend "s3" {
  #   bucket = "CHANGE-ME-TO-THE-S3-BUCKET-NAME"
  #   key    = "codepipeline-lambda"
  #   region = "us-east-1"
  # }
  ...
}
```

### Terraform Apply & Git clone Repo
- cd to `infra`
```sh
terraform init
terraform apply -auto-approve
```
- copy git address from output of `terraform apply`
  - cd into parent directory
  - git clone THE-NEW-REPO-NAME-TERRAFORM-CREATED
- move contents into aws repo folder
```sh
mv sample-aws-lambda/* AWS-REPO-FOLDER-NAME
```
- uncomment pipeline and change s3 bucket name to your s3 bucket name
```sh
terraform {
  backend "s3" {
    bucket = "CHANGE-ME-TO-THE-S3-BUCKET-NAME"
    key    = "codepipeline-lambda"
    region = "us-east-1"
  }
  ...
}

```


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