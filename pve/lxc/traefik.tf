# Traefik Container
module "lxc_traefik" {
	
	providers = {
		proxmox = proxmox
	}

	user = var.user
	proxmox = var.proxmox
	domain = var.domain
	vztmpl = var.vztmpl
	consul = var.consul
	data = var.lxc.traefik

	source = "../../modules/terraform/proxmox/lxc_traefik"

	dependencies = [
		module.lxc_consul.id
	]
}