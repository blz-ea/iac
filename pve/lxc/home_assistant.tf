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
		module.lxc_consul.provisioner_id
	]

	tags = [
	  "traefik.enable=true",
	  "traefik.http.routers.${var.lxc.hass.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.lxc.hass.container_name}.rule=Host(`${var.lxc.hass.hostname}`)",
	  "traefik.http.routers.${var.lxc.hass.container_name}.tls.certResolver=${var.lxc.hass.cert_resolver}",
	  "traefik.http.routers.${var.lxc.hass.container_name}.service=${var.lxc.hass.container_name}@consulcatalog",
  ]
}