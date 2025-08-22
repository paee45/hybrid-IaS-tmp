# File: main.tf

# Terraform configuration for setting up HashiCorp Vault on Docker using Docker Compose.
# This configuration includes steps to install Docker, prepare necessary directories,
# run Docker Compose to start the Vault container, and initialize Vault.

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

# Resource to install Docker if it is not already installed.
resource "null_resource" "install_docker" {
  provisioner "local-exec" {
    command = <<EOT
      # Detect OS
      OS=$(uname -s)
      if [ "$OS" = "Linux" ]; then
        # Install Docker on Linux
        if ! command -v docker &> /dev/null; then
          sudo apt-get update
          sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
          sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
          sudo apt-get update
          sudo apt-get install -y docker-ce
          sudo systemctl start docker
          sudo systemctl enable docker
          sudo usermod -aG docker $USER
          echo "Docker installed and started successfully on Linux."
        else
          echo "Docker is already installed on Linux."
        fi
      elif [ "$OS" = "Darwin" ]; then
        # Install Docker on macOS
        if ! command -v docker &> /dev/null; then
          brew install --cask docker
          open /Applications/Docker.app
          while ! docker system info > /dev/null 2>&1; do
            echo "Waiting for Docker to launch..."
            sleep 5
          done
          echo "Docker installed and started successfully on macOS."
        else
          echo "Docker is already installed on macOS."
        fi
      else
        echo "Unsupported OS: $OS"
        exit 1
      fi
    EOT
  }
}

# Resource to prepare necessary directories for Vault configuration and data.
resource "null_resource" "prepare_directories" {
  provisioner "local-exec" {
    command = "mkdir -p /Users/pa/Documents/_Pa/devop/docker-data/hashicorp-vault-local/config"
  }
}

# Resource to run Docker Compose and start the Vault container.
resource "null_resource" "run_docker_compose" {
  provisioner "local-exec" {
    command = "docker-compose -f ${path.module}/docker-compose.yml up -d"
  }
  depends_on = [null_resource.install_docker, null_resource.prepare_directories]
}

# Resource to initialize and unseal Vault.
resource "null_resource" "initialize_vault" {
  provisioner "local-exec" {
    command = <<EOT
      # Wait for Vault to be ready
      while ! curl -s http://127.0.0.1:8200/v1/sys/seal-status > /dev/null; do
        echo "Waiting for Vault to be ready..."
        sleep 5
      done

      echo "Vault is ready."

      export VAULT_ADDR='http://127.0.0.1:8200'
      vault operator init -key-shares=1 -key-threshold=1 -format=json > /Users/pa/Documents/_Pa/devop/docker-data/hashicorp-vault-local/config/init-keys.json
      echo "Vault initialized successfully."

      vault operator unseal $(jq -r ".unseal_keys_b64[0]" /Users/pa/Documents/_Pa/devop/docker-data/hashicorp-vault-local/config/init-keys.json)
      echo "Vault unsealed successfully."

      vault login $(jq -r ".root_token" /Users/pa/Documents/_Pa/devop/docker-data/hashicorp-vault-local/config/init-keys.json)
      echo "Logged into Vault successfully."
    EOT
    environment = {
      VAULT_ADDR = "http://127.0.0.1:8200"
    }
  }
  depends_on = [null_resource.run_docker_compose]
}

# Output the Vault initialization keys and root token.
output "vault_init_keys" {
  value     = file("/Users/pa/Documents/_Pa/devop/docker-data/hashicorp-vault-local/config/init-keys.json")
  sensitive = true
}