# Cognizant Lab Practice

## Steps
- AWS user assigned policy `AdministratorAccess`
- github credentials created.

## Clone Infra, Lambda
- git clone [https://github.com/DevOpsTestLab/infra](https://github.com/DevOpsTestLab/infra)
- git clone [https://github.com/DevOpsTestLab/sample-aws-lambda](https://github.com/DevOpsTestLab/sample-aws-lambda)

### Infra Folder
- Add Terraform parameter store variables to `infra / main.tf`
```sh
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
- add sonarcloud token variable to `infra / variable.tf`
```sh
variable "sonar_token" {
  description = "SonarCloud token"
  type        = string
}
```
- add sonarcloud token secret and name variables to `infra / terraform.tfvars`
```sh
org_name   = "revature"
team_name  = "devops"
project_id = "1"
region     = "us-east-1"

sonar_token = "g4e................py"
```
- codepipeline
  - add `force_destroy = true` to `infra / modules / codepipeline / main.tf`
```sh
#resource "aws_s3_bucket" "codepipeline_bucket" {
#  bucket        = "${var.s3_bucket_namespace}-codepipeline-bucket"
  force_destroy = true
#}

```
#### Code Build files `infra / modules / codepipeline / templates`
- `buildspec_build.yaml`
```sh
- docker build -t $IMAGE_URI ./lambda
```

- `buildspec_scan.yaml`
```sh
- sonar-scanner -Dsonar.projectKey=`CHANGE ME TO PROJECT NAME` -Dsonar.sources=. -Dsonar.login=${SONARQUBE_TOKEN} -Dsonar.organization=${SONAR_ORG} -Dsonar.host.url=${SONARQUBE_ENDPOINT}
```

- deploy
  - change terraform -terraform -auto-approve
  - move hclq to build stage & add `-auto-approve`
```sh
curl -sSLo install.sh https://install.hclq.sh
sh install.sh -d /usr/local/bin/
terraform apply -auto-approve
```


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