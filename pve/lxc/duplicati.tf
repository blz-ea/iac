# Dupliati Container
module "lxc_duplicati" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.duplicati
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_duplicati"

	dependencies = [
		module.lxc_consul.id
	]
}