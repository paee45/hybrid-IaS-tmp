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

resource "null_resource" "install_docker" {
  provisioner "remote-exec" {
    inline = [
      "bash /home/pa/home-assistance/terraform/scripts/install_docker.sh"
    ]

    connection {
      type        = "ssh"
      user        = var.username
      private_key = file("~/.ssh/id_rsa")
      host        = var.home_server_ip
    }
  }
}

resource "null_resource" "run_docker_compose" {
  provisioner "local-exec" {
    command = "docker-compose -f ${path.module}/docker-compose/docker-compose.yml up -d"
  }
}

output "docker_installation_status" {
  value = "Docker and Docker Compose have been installed and the services are running."
}

output "docker_compose_status" {
  value = "Docker Compose has been executed and the services are running."
}