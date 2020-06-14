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
		module.lxc_consul.provisioner_id
	]

	tags = [
		"traefik.enable=true",
		"traefik.http.routers.${var.lxc.plex.container_name}.entryPoints=https",
		"traefik.http.routers.${var.lxc.plex.container_name}.rule=Host(`${var.lxc.plex.hostname}`)",
		"traefik.http.routers.${var.lxc.plex.container_name}.tls.certResolver=${var.lxc.plex.cert_resolver}",
		"traefik.http.routers.${var.lxc.plex.container_name}.service=${var.lxc.plex.container_name}@consulcatalog",
	]
}