# Traefik Container
module "lxc_traefik" {
	
	providers = {
		proxmox = proxmox
	}

	user = var.user
	proxmox = var.proxmox
	domain = var.domain
	vztmpl = var.vztmpl
	consul = var.consul
	data = var.lxc.traefik

	source = "../../modules/terraform/proxmox/lxc_traefik"
	
	environment = [
		"CLOUDFLARE_API_KEY=${var.cloudflare.api_key}",
		"CLOUDFLARE_EMAIL=${var.cloudflare.email}",
	]

	cli_options = [
		"--entryPoints.http.address=:80",
    "--entryPoints.https.address=:443",

		# Consul Catalog provider for dynamic configuration
		"--providers.consulcatalog=true",
		"--providers.consulcatalog.exposedByDefault=false",
		"--providers.consulcatalog.prefix=traefik",
		"--providers.consulcatalog.endpoint.scheme=${var.consul.default.scheme}",
		"--providers.consulcatalog.endpoint.tls.insecureSkipVerify=true",
		"--providers.consulcatalog.endpoint.datacenter=${var.consul.default.data_center}",
		"--providers.consulcatalog.endpoint.address=${var.consul.default.host}:${var.consul.default.port}",
		# "--providers.consulcatalog.endpoint.httpAuth.username=username",
		# "--providers.consulcatalog.endpoint.httpAuth.password=password",

		# Consul KV Store provider for dynamic configuration
		"--providers.consul=true",
		"--providers.consul.rootkey=traefik",
		"--providers.consul.tls.insecureSkipVerify=true",
		# "--providers.consul.username=username",
		# "--providers.consul.password=password",
		"--providers.consul.endpoints=${var.consul.default.scheme}://${var.consul.default.host}:${var.consul.default.port}",

    "--certificatesResolvers.cloudflare.acme.email=${var.cloudflare.email}",
    "--certificatesResolvers.cloudflare.acme.storage=/opt/traefik/acme.json",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=30",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53",
	]

	dynamic_config = [
		# TODO: Authentication
		# [WIP] `Authelia` will be an authentication service for Traefik
		"traefik.enable=true",
		"traefik.http.routers.${var.lxc.traefik.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.lxc.traefik.container_name}.rule=Host(`${var.lxc.traefik.hostname}`)",
		"traefik.http.routers.${var.lxc.traefik.container_name}.tls.certResolver=cloudflare",
	  "traefik.http.routers.${var.lxc.traefik.container_name}.service=api@internal",
	]

	dependencies = [
		module.lxc_consul.provisioner_id
	]
}