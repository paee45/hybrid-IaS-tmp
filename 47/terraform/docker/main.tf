# Specify the local provider with version constraint
provider "local" {
  version = "~> 2.1"
}

# Specify the null provider with version constraint
provider "null" {
  version = "~> 3.0"
}

variable "username" {
  description = "SSH username for Linux"
  type        = string
}

variable "home_server_ip" {
  description = "IP address of the home server"
  type        = string
}

# Define a null resource to install Docker and Docker Compose on a remote Debian machine
resource "null_resource" "install_docker" {
  # Use the remote-exec provisioner to run commands on the remote machine
  provisioner "remote-exec" {
    inline = [
      # Update the package list
      "sudo apt-get update",
      # Install required packages for Docker installation
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      # Add Docker's official GPG key
      "curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      # Set up the Docker stable repository
      "echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      # Update the package list again
      "sudo apt-get update",
      # Install Docker packages
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      # Download the current stable release of Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -oP '\"tag_name\": \"\K(.*)(?=\")')/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      # Apply executable permissions to the Docker Compose binary
      "sudo chmod +x /usr/local/bin/docker-compose",
      # Run a test Docker container to verify the Docker installation
      "sudo docker run hello-world",
      # Verify Docker Compose installation
      "docker-compose --version"
    ]

    # Define the connection details for the remote machine
    connection {
      type        = "ssh"
      user        = var.username
      private_key = file("~/.ssh/id_rsa")  # Path to your SSH private key
      host        = var.home_server_ip  # Replace with your remote host address
    }
  }
}

# Output the status of Docker and Docker Compose installation
output "docker_installation_status" {
  value = "Docker and Docker Compose have been installed and verified on the remote Debian machine."
}