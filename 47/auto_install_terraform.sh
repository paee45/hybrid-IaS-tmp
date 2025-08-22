#!/bin/bash

#auto detect the OS and install terraform

# Function to install Terraform on CentOS/Red Hat
install_terraform_centos() {
  sudo dnf install -y yum-utils
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  sudo dnf install -y terraform
}

# Function to install Terraform on Ubuntu/Debian
install_terraform_ubuntu() {
  sudo apt-get update -y
  sudo apt-get install -y gnupg software-properties-common curl
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update -y
  sudo apt-get install -y terraform
}

# Function to install Terraform on macOS
install_terraform_macos() {
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
}

# Detect the OS and call the appropriate function
if [ -f /etc/redhat-release ]; then
  install_terraform_centos
elif [ -f /etc/lsb-release ]; then
  install_terraform_ubuntu
elif [ "$(uname)" == "Darwin" ]; then
  install_terraform_macos
else
  echo "Unsupported OS"
  exit 1
fi

# Verify Terraform installation
terraform --version