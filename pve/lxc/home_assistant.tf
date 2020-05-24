# Home Assistant Container
module "lxc_home_assistant" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.hass
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_home_assistant"

	dependencies = [
		module.lxc_consul.id
	]
}