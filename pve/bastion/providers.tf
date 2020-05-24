provider "docker" {
  host = "ssh://${var.user.name}@${digitalocean_droplet.bastion.ipv4_address}:${var.bastion.ssh.access_port}"
}
