# FILE: variables.tf

# Define variables for SSH credentials and remote host details
variable "ssh_user" {
  description = "SSH user"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key"
  type        = string
  sensitive   = true
}

variable "remote_host" {
  description = "Remote host IP address"
  type        = string
}

# Define variables for GitHub credentials and repository
variable "github_username" {
  description = "GitHub username"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository to clone"
  type        = string
}

variable "git_user_name" {
  description = "Git user name"
  type        = string
}

variable "git_user_email" {
  description = "Git user email"
  type        = string
}