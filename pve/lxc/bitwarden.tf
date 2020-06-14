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
		module.lxc_consul.provisioner_id
	]

	tags = {
		http = [
			"traefik.enable=true",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}.entryPoints=https",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}.rule=Host(`${var.lxc.bitwarden.hostname}`)",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}.tls.certResolver=${var.lxc.bitwarden.cert_resolver}",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}.service=${var.lxc.bitwarden.container_name}@consulcatalog",
		]

		wss = [
			"traefik.enable=true",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}_wss.entryPoints=https",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}_wss.rule=Host(`${var.lxc.bitwarden.hostname}`) && Path(`/notifications/hub`)",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}_wss.tls.certResolver=${var.lxc.bitwarden.cert_resolver}",
			"traefik.http.routers.${var.lxc.bitwarden.container_name}_wss.service=${var.lxc.bitwarden.container_name}-wss@consulcatalog",
		]
	}
}