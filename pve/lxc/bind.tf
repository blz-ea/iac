# DNS Server
module "lxc_bind" {
	
	providers = {
		proxmox = proxmox
	}

	user 			      = var.user
	proxmox 	      = var.proxmox
	domain 		      = var.domain
	vztmpl 		      = var.vztmpl
	container_cfg   = var.lxc.bind
  data            = merge(var.workspace.bind, { bind_forwarders: concat(var.workspace.bind.bind_forwarders, [module.lxc_pihole.ip_address]) })
	
  consul 		      = var.consul
	source 		      = "../../modules/terraform/proxmox/lxc_bind"
}