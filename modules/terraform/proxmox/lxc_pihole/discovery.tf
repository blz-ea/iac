data "consul_nodes" "nodes" {
  query_options {
    # Last bit creates hacky dependency, `depends_on` always triggers data source read
    datacenter = "${var.consul.default.data_center}${replace(null_resource.provision.id, "/.*/", "")}"
  }
}

locals {
	node = [ for node in data.consul_nodes.nodes.nodes: node if node.name == local.container_name ][0]
}

# HTTP Service
resource "consul_agent_service" "service" {
	address = local.node.address
  name = var.data.container_name
  port = 80
  tags = [
	  "traefik.enable=true",
		"traefik.http.middlewares.pihole-replace-prefix.replacePathRegex.regex=^/(.*)",
	  "traefik.http.middlewares.pihole-replace-prefix.replacePathRegex.replacement=/admin/$1",
		
		"traefik.http.routers.${var.data.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.data.container_name}.rule=Host(`${var.data.hostname}`)",
		"traefik.http.routers.${var.data.container_name}.middlewares=pihole-replace-prefix",  
		"traefik.http.routers.${var.data.container_name}.tls.certResolver=${var.data.cert_resolver}",
	  "traefik.http.routers.${var.data.container_name}.service=${var.data.container_name}@consulcatalog",
  ]

	depends_on = [ null_resource.provision ]
}
