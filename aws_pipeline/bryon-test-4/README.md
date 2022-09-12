# Cognizant Lab Practice

## Steps
- AWS user assigned to group admin
- github credentials

Clone Infra, Lambda

Infra
- Change variables infra / terrafrom.tfvars

Lambda
- change Docker file requirement to requirements
- versions.tf  -change s3 bucket to the one made.

Code Build files
- build.yaml
  - infra / modules / codepipeline / templates / build.yaml -cd into lambda

- scan.yaml
  - Sonar setup -copy values
  - change projectKey=NEW-NAME
  - add parameter store vars

- deploy
  - change terraform -terraform -auto-approve