output "codepipeline" {
  value = module.codepipeline.codepipeline_configs.codepipeline
}
output "codecommit" {
  value = module.codecommit.codecommit_configs.clone_repository_url
}
output "ecrrepo" {
  value = module.ecr.ecr_configs.ecr_repo_url
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "codecommit_module" {
  value = module.codecommit.codecommit_configs
}
