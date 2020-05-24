# Jellyfin Container
module "lxc_jellyfin" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.jellyfin
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_jellyfin"

	dependencies = [
		module.lxc_consul.id
	]
}