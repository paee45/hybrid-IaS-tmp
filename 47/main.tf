# FILE: main.tf
# Install Docker and Git, set up GitHub credentials, and clone a repository on a remote Linux machine

provider "null" {
  # No configuration needed for null provider
}

provider "tls" {
  # No configuration needed for tls provider
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "setup_environment" {
  source = "./modules/setup_environment"

  ssh_user        = var.ssh_user
  ssh_private_key = var.ssh_private_key
  remote_host     = var.remote_host
  github_username = var.github_username
  github_token    = var.github_token
  github_repo     = var.github_repo
  git_user_name   = var.git_user_name
  git_user_email  = var.git_user_email
}

# Output a message indicating the completion of the setup
output "message" {
  value = "Docker and Git installation, GitHub credential setup, and repository cloning are complete."
}