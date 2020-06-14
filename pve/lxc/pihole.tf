# Pihole Container
module "lxc_pihole" {
	
	providers = {
		proxmox = proxmox
	}

	user 			= var.user
	proxmox 	= var.proxmox
	domain 		= var.domain
	vztmpl 		= var.vztmpl
	data 			= var.lxc.pihole
	consul 		= var.consul

	source 		= "../../modules/terraform/proxmox/lxc_pihole"

	dependencies = [
		module.lxc_consul.provisioner_id
	]

	tags = [
	  "traefik.enable=true",
		"traefik.http.middlewares.pihole-replace-prefix.replacePathRegex.regex=^/(.*)",
	  "traefik.http.middlewares.pihole-replace-prefix.replacePathRegex.replacement=/admin/$1",
		
		"traefik.http.routers.${var.lxc.pihole.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.lxc.pihole.container_name}.rule=Host(`${var.lxc.pihole.hostname}`)",
		"traefik.http.routers.${var.lxc.pihole.container_name}.middlewares=pihole-replace-prefix",  
		"traefik.http.routers.${var.lxc.pihole.container_name}.tls.certResolver=${var.lxc.pihole.cert_resolver}",
	  "traefik.http.routers.${var.lxc.pihole.container_name}.service=${var.lxc.pihole.container_name}@consulcatalog",
  ]
}