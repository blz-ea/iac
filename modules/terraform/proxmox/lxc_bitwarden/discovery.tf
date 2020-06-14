
data "consul_nodes" "nodes" {
  query_options {
		# Last bit creates hacky dependency, `depends_on` always triggers data source read
    datacenter = "${var.consul.default.data_center}${replace(null_resource.consul_agent.id, "/.*/", "")}"
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
  tags = var.tags.http

	depends_on = [ null_resource.provisioner ]
}

# WSS Service
resource "consul_agent_service" "service_wss" {
	address = local.node.address
  name = "${var.data.container_name}_wss"
  port = 3012
  tags = var.tags.wss

	depends_on = [ null_resource.provisioner ]
}
