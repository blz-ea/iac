# Consul Server Container
module "lxc_consul" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	consul 		= var.consul
	data 			= var.lxc.consul

	source 		= "../../modules/terraform/proxmox/lxc_consul"
}