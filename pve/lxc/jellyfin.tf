# Jellyfin Container
module "lxc_jellyfin" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.jellyfin
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_jellyfin"

	dependencies = [
		module.lxc_consul.provisioner_id
	]

	tags = [
		"traefik.enable=true",
	  "traefik.http.routers.${var.lxc.jellyfin.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.lxc.jellyfin.container_name}.rule=Host(`${var.lxc.jellyfin.hostname}`)",
	  "traefik.http.routers.${var.lxc.jellyfin.container_name}.tls.certResolver=${var.lxc.jellyfin.cert_resolver}",
	  "traefik.http.routers.${var.lxc.jellyfin.container_name}.service=${var.lxc.jellyfin.container_name}@consulcatalog",
	]
}