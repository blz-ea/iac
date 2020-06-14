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

	tags = [
	  "traefik.enable=true",
	  "traefik.http.routers.${var.lxc.consul.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.lxc.consul.container_name}.rule=Host(`${var.lxc.consul.hostname}`)",
	  "traefik.http.routers.${var.lxc.consul.container_name}.tls.certResolver=${var.lxc.consul.cert_resolver}",
	  "traefik.http.routers.${var.lxc.consul.container_name}.service=${var.lxc.consul.container_name}@consulcatalog",
  ]
	
}