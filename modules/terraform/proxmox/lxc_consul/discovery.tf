resource "consul_agent_service" "service" {
	depends_on = [
		null_resource.provision
	]
  address = local.container_ip_address
	name = var.data.container_name
  port = 8500
  tags = [
	  "traefik.enable=true",
	  "traefik.http.routers.${var.data.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.data.container_name}.rule=Host(`${var.data.hostname}`)",
	  "traefik.http.routers.${var.data.container_name}.tls.certResolver=${var.data.cert_resolver}",
	  "traefik.http.routers.${var.data.container_name}.service=${var.data.container_name}@consulcatalog",
  ]
}
