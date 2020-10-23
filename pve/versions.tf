terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    docker = {
      source = "terraform-providers/docker"
    }
    null = {
      source = "hashicorp/null"
    }
    proxmox = {
      source = "blz-ea/proxmox"
    }
  }
  required_version = ">= 0.13"
}
