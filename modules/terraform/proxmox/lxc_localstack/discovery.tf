
data "consul_nodes" "nodes" {
  query_options {
		# Last bit creates hacky dependency, `depends_on` always triggers data source read
    datacenter = "${var.consul.default.data_center}${replace(null_resource.provision.id, "/.*/", "")}"
  }
}

locals {
	node = [ for node in data.consul_nodes.nodes.nodes: node if node.name == local.container_name ][0]
}

# UI Service
resource "consul_agent_service" "service" {
	address = local.node.address
  name = var.data.container_name
  port = 8080
  tags = [
	  "traefik.enable=true",
	  "traefik.http.routers.${var.data.container_name}.entryPoints=https",
	  "traefik.http.routers.${var.data.container_name}.rule=Host(`${var.data.hostname}`)",
	  "traefik.http.routers.${var.data.container_name}.tls.certResolver=${var.data.cert_resolver}",
	  "traefik.http.routers.${var.data.container_name}.service=${var.data.container_name}@consulcatalog",
  ]

	depends_on = [ null_resource.provision ]
}

# Edge Endpoint Service
resource "consul_agent_service" "edge_service" {
	address = local.node.address
  name = "${var.data.container_name}-edge"
  port = 4566
  tags = [
	  "traefik.enable=true",
	  "traefik.http.routers.${var.data.container_name}_edge.entryPoints=https",
	  "traefik.http.routers.${var.data.container_name}_edge.rule=Host(`${var.data.hostname_endpoint}`)",
	  "traefik.http.routers.${var.data.container_name}_edge.tls.certResolver=${var.data.cert_resolver}",
	  "traefik.http.routers.${var.data.container_name}_edge.service=${var.data.container_name}-edge@consulcatalog",
  ]

	depends_on = [ null_resource.provision ]
}
