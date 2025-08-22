# Note:
# Replace the placeholders <vista_endpoint> and <tungpo_endpoint> with the actual endpoint values
# in each file before applying the configuration.
#
# Best Practice:
# - Ensure that the endpoint values are accurate and up-to-date.
# - Validate the configuration with `terraform validate` before applying.
# - Use version control to track changes to this file.
# - Consider using variables or a secrets management tool to handle sensitive information.
#Replace <vista_endpoint> and <tungpo_endpoint> with the actual endpoint values in each file.

provider "docker" {}

resource "docker_image" "wireguard" {
  name = "linuxserver/wireguard"
}

resource "docker_container" "tungpo" {
  name  = "tungpo"
  image = docker_image.wireguard.latest

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=Etc/UTC",
    "SERVERURL=<tungpo_endpoint>", #Replace <vista_endpoint> and <tungpo_endpoint> with the actual endpoint values in each file.
    "SERVERPORT=51821",
    "PEERS=vista",
    "PEERDNS=auto",
    "INTERNAL_SUBNET=10.0.0.0/24"
  ]

  volumes {
    host_path      = "${path.module}/config/tungpo"
    container_path = "/config"
  }

  ports {
    internal = 51821
    external = 51821
    protocol = "udp"
  }

  restart = "unless-stopped"
}