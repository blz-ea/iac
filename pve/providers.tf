#############################################################
# Providers
#############################################################
provider "proxmox" {
  virtual_environment {
    endpoint = var.proxmox_api_url
    username = var.proxmox_api_username
    password = var.proxmox_api_password
    insecure = var.proxmox_api_tls_insecure
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "digitalocean" {
  token = var.digital_ocean_api_key
}