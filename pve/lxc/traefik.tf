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
		"--providers.consulCatalog=true",
		"--providers.consulCatalog.exposedByDefault=false",
		"--providers.consulCatalog.prefix=traefik",
		"--providers.consulCatalog.endpoint.scheme=http",
		"--providers.consulCatalog.endpoint.tls.insecureSkipVerify=true",
		"--providers.consulCatalog.endpoint.datacenter=devset.app",
		"--providers.consulCatalog.endpoint.address=http://127.0.0.1:8500",
		# "--providers.consulCatalog.endpoint.httpAuth.username=username",
		# "--providers.consulCatalog.endpoint.httpAuth.password=password",

		# Consul KV Store provider for dynamic configuration
		"--providers.consul=true",
		"--providers.consul.rootkey=traefik",
		"--providers.consul.tls.insecureSkipVerify=true",
		# "--providers.consul.username=username",
		# "--providers.consul.password=password",
		"--providers.consul.endpoints=http://127.0.0.1:8500",

    "--certificatesResolvers.cloudflare.acme.email=${var.cloudflare.email}",
    "--certificatesResolvers.cloudflare.acme.storage=/letsencrypt/acme.json",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=30",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53",
	]

	dependencies = [
		module.lxc_consul.id
	]
}