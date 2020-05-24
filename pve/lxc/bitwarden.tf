# Bitwarden Container
module "lxc_bitwarden" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.bitwarden
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_bitwarden"

	dependencies = [
		module.lxc_consul.id
	]
}