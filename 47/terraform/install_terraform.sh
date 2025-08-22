#!/bin/bash

# Function to check the OS and architecture
detect_os_arch() {
  OS=$(uname | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)

  case $ARCH in
    x86_64)
      ARCH="amd64"
      ;;
    aarch64)
      ARCH="arm64"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  echo "$OS" "$ARCH"
}

# Function to download and install Terraform
install_terraform() {
  OS_ARCH=$(detect_os_arch)
  OS=$(echo $OS_ARCH | cut -d ' ' -f 1)
  ARCH=$(echo $OS_ARCH | cut -d ' ' -f 2)

  TERRAFORM_VERSION="1.0.11"
  DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"

  echo "Downloading Terraform from $DOWNLOAD_URL..."
  curl -LO $DOWNLOAD_URL

  echo "Installing unzip..."
  sudo apt-get update
  sudo apt-get install -y unzip

  echo "Unzipping Terraform..."
  unzip terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip

  echo "Installing Terraform..."
  sudo mv terraform /usr/local/bin/

  echo "Cleaning up..."
  rm terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip

  echo "Terraform installed successfully!"
  /usr/local/bin/terraform version

  echo "If you still encounter the 'command not found' error, ensure that /usr/local/bin is in your PATH."
  echo "You can add it to your PATH by adding the following line to your shell configuration file (e.g., .bashrc, .zshrc):"
  echo 'export PATH=$PATH:/usr/local/bin'
}

install_terraform