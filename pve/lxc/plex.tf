# Plex Media Server Container
module "lxc_plex" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.plex
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_plex"

	dependencies = [
		module.lxc_consul.id
	]
}