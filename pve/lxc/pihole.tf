# Pihole Container
module "lxc_pihole" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.pihole
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_pihole"

	dependencies = [
		module.lxc_consul.id
	]
}