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
		module.lxc_consul.provisioner_id
	]

	tags = {
		webui = [
			"traefik.enable=true",
			"traefik.http.routers.${var.lxc.localstack.container_name}.entryPoints=https",
			"traefik.http.routers.${var.lxc.localstack.container_name}.rule=Host(`${var.lxc.localstack.hostname}`)",
			"traefik.http.routers.${var.lxc.localstack.container_name}.tls.certResolver=${var.lxc.localstack.cert_resolver}",
			"traefik.http.routers.${var.lxc.localstack.container_name}.service=${var.lxc.localstack.container_name}@consulcatalog",
		]
		edge = [
			"traefik.enable=true",
			"traefik.http.routers.${var.lxc.localstack.container_name}_edge.entryPoints=https",
			"traefik.http.routers.${var.lxc.localstack.container_name}_edge.rule=Host(`${var.lxc.localstack.hostname_endpoint}`)",
			"traefik.http.routers.${var.lxc.localstack.container_name}_edge.tls.certResolver=${var.lxc.localstack.cert_resolver}",
			"traefik.http.routers.${var.lxc.localstack.container_name}_edge.service=${var.lxc.localstack.container_name}-edge@consulcatalog",
		]
	}
}