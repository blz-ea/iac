# Localstack Container
module "lxc_localstack" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.localstack
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_localstack"

	dependencies = [
		module.lxc_consul.id
	]
}