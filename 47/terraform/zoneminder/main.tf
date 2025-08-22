# File: main.tf

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
    docker-compose = {
      source  = "logzio/docker-compose"
      version = "~> 0.1.0"
    }
  }
}

provider "docker" {}

provider "docker-compose" {}

resource "docker_compose_yaml" "zoneminder" {
  source = file("${path.module}/docker-compose.yml")
}