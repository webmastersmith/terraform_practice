terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32.0"
      #Will allow installation of 4.29.1 and 4.29.10 but not 4.30.0
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.2"
    }
  }

  # add terraform state to bucket. this has to be applied after bucket is created.
  # backend "s3" {
  #   bucket = "terra-ptkgux"
  #   key    = "terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# create random string
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  numeric = false
  lower   = true
}

# create aws bucket name with random string for uniqueness
locals {
  s3_name = "terraform-functions-${random_string.suffix.result}"
}
# create bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = local.s3_name
  # allow terraform to destroy bucket with contents
  force_destroy = true

  # object_lock_enabled = true
}

# block all objects from being public
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# inform Access Control List bucket is private
resource "aws_s3_bucket_acl" "terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  acl    = "private"
}

# ## versioning
# resource "aws_s3_bucket_versioning" "versioning_terraform-state" {
#   bucket = aws_s3_bucket.terraform-state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# ## This if for encrypting bucket contents. Must have an KMS key already made.
# ## get arn
# data "aws_kms_alias" "s3" {
#   name = "alias/CHANGE-ME-TO-YOUR-KMS-KEY-NAME"
# }

# ## encrypt data with key
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform-state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = data.aws_kms_alias.s3.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }
# ## End bucket encryption

# add object to s3 through terraform
data "archive_file" "lambda_hello_bryon" {
  type = "zip"

  source_dir  = "${path.module}/hello-bryon"
  output_path = "${path.module}/hello-bryon.zip"
}

resource "aws_s3_object" "lambda_hello_bryon" {
  bucket = aws_s3_bucket.terraform-state.id

  key    = "hello-bryon.zip"
  source = data.archive_file.lambda_hello_bryon.output_path

  etag = filemd5(data.archive_file.lambda_hello_bryon.output_path)
}


# create the lambda function
resource "aws_lambda_function" "hello_bryon" {
  function_name = "HelloBryon"

  s3_bucket = aws_s3_bucket.terraform-state.id
  s3_key    = aws_s3_object.lambda_hello_bryon.key

  runtime = "nodejs16.x"
  handler = "hello.handler"

  source_code_hash = data.archive_file.lambda_hello_bryon.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello_bryon" {
  name = "/aws/lambda/${aws_lambda_function.hello_bryon.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "function_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.hello_bryon.function_name
}


output "bucket_name" {
  value = aws_s3_bucket.terraform-state.id
}
output "bucket_domain_name" {
  value = "https://${aws_s3_bucket.terraform-state.bucket_domain_name}"
}

