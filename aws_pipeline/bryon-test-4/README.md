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


# Pipeline teardown
- manually delete
  - items in s3 bucket created for lambda.
    - aws s3 rm --recursive s3://BUCKET-NAME
  - role create: dev_lambda_role
  - lambda function
- terraform destroy -auto-approve  <!-- infra folder -->