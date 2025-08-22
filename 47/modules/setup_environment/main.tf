# FILE: modules/setup_environment/main.tf

resource "null_resource" "setup_environment" {
  # Connection details for the remote host
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key)
    host        = var.remote_host
  }

  # Use the remote-exec provisioner to run the installation script on the remote host
  provisioner "remote-exec" {
    inline = [
      # Function to install Docker on CentOS/Red Hat
      "install_docker_centos() {",
      "  sudo dnf update -y",
      "  sudo dnf install -y yum-utils device-mapper-persistent-data lvm2",
      "  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
      "  sudo dnf install -y docker-ce docker-ce-cli containerd.io",
      "  sudo systemctl start docker",
      "  sudo systemctl enable docker",
      "}",

      # Function to install Docker on Ubuntu/Debian
      "install_docker_ubuntu() {",
      "  sudo apt-get update -y",
      "  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",
      "  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "  echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "  sudo apt-get update -y",
      "  sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      "  sudo systemctl start docker",
      "  sudo systemctl enable docker",
      "}",

      # Function to install Docker on macOS
      "install_docker_macos() {",
      "  brew install --cask docker",
      "}",

      # Function to install Git on CentOS/Red Hat
      "install_git_centos() {",
      "  sudo dnf install -y git",
      "}",

      # Function to install Git on Ubuntu/Debian
      "install_git_ubuntu() {",
      "  sudo apt-get update -y",
      "  sudo apt-get install -y git",
      "}",

      # Function to install Git on macOS
      "install_git_macos() {",
      "  brew install git",
      "}",

      # Detect the OS and call the appropriate functions
      "if [ -f /etc/redhat-release ]; then",
      "  install_docker_centos",
      "  install_git_centos",
      "elif [ -f /etc/lsb-release ]; then",
      "  install_docker_ubuntu",
      "  install_git_ubuntu",
      "elif [ \"$(uname)\" == \"Darwin\" ]; then",
      "  install_docker_macos",
      "  install_git_macos",
      "else",
      "  echo 'Unsupported OS'",
      "  exit 1",
      "fi",

      # Set up GitHub credentials
      "git config --global user.name \"${var.git_user_name}\"",
      "git config --global user.email \"${var.git_user_email}\"",
      "git config --global credential.helper store",

      # Create a credentials file
      "echo \"https://${var.github_username}:${var.github_token}@github.com\" > ~/.git-credentials",

      # Clone the repository
      "git clone https://github.com/${var.github_username}/${var.github_repo}.git",

      # Verify Docker and Git installation
      "docker --version",
      "git --version"
    ]
  }
}