locals {
  pve = module.vars.workspace.proxmox.nodes.pve
}

provider "proxmox" {
  virtual_environment {
    endpoint = local.pve.api.url
    username = local.pve.api.username
    password = local.pve.api.password
    insecure = local.pve.api.tls_insecure
  }
}

provider "consul" {
  version = "2.7.0"
  address     = "${module.vars.workspace.consul.default.host}:${module.vars.workspace.consul.default.port}"
  datacenter  = module.vars.workspace.consul.default.data_center
  scheme      = module.vars.workspace.consul.default.scheme
}

provider "cloudflare" {
  email   = module.vars.workspace.cloudflare.email
  api_key = module.vars.workspace.cloudflare.api_key
}

provider "digitalocean" {
  token = module.vars.workspace.digital_ocean.api_key
}
