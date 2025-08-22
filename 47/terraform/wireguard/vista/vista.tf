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

resource "docker_image" "wireguard" {
  name = "linuxserver/wireguard"
}

resource "docker_compose_yaml" "vista" {
  source = <<EOF
version: '3.7'

services:
  vista:
    image: ${docker_image.wireguard.name}
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - SERVERURL=${var.vista_endpoint}
      - SERVERPORT=51820
      - PEERS=tungpo
      - PEERDNS=auto
      - INTERNAL_SUBNET=10.0.0.0/24
    volumes:
      - ./config/vista:/config
    ports:
      - "51820:51820/udp"
    restart: unless-stopped
EOF
}

variable "vista_endpoint" {
  description = "The endpoint for the Vista WireGuard server"
  type        = string
}

variable "tungpo_endpoint" {
  description = "The endpoint for the Tungpo WireGuard peer"
  type        = string
}