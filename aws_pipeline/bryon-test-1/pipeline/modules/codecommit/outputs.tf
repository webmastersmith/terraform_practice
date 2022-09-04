# must reference in root: module.codecommit.codecommit_configs
output "codecommit_configs" {
  value = {
    repository_name      = aws_codecommit_repository.codecommit_repo.repository_name
    default_branch       = aws_codecommit_repository.codecommit_repo.default_branch
    ssh_url              = aws_codecommit_repository.codecommit_repo.clone_url_ssh
    clone_repository_url = aws_codecommit_repository.codecommit_repo.clone_url_http
  }
}
