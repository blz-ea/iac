
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
	  "traefik.http.routers.${var.data.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.data.container_name}.rule=Host(`${var.data.hostname}`)",
	  "traefik.http.routers.${var.data.container_name}.tls.certResolver=${var.data.cert_resolver}",
	  "traefik.http.routers.${var.data.container_name}.service=${var.data.container_name}@consulcatalog",
  ]

	depends_on = [ null_resource.provision ]
}

# WSS Service
resource "consul_agent_service" "service_wss" {
	address = local.node.address
  name = "${var.data.container_name}_wss"
  port = 3012
  tags = [
	  "traefik.enable=true",
	  "traefik.http.routers.${var.data.container_name}_wss.entryPoints=https",
	  "traefik.http.routers.${var.data.container_name}_wss.rule=Host(`${var.data.hostname}`) && Path(`/notifications/hub`)",
	  "traefik.http.routers.${var.data.container_name}_wss.tls.certResolver=${var.data.cert_resolver}",
	  "traefik.http.routers.${var.data.container_name}_wss.service=${var.data.container_name}-wss@consulcatalog",
  ]

	depends_on = [ null_resource.provision ]
}
