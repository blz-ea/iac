
data "consul_nodes" "nodes" {
  query_options {
		# Last bit creates hacky dependency, `depends_on` always triggers data source read
    datacenter = "${var.consul.default.data_center}${replace(null_resource.consul_agent.id, "/.*/", "")}"
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
  tags = var.tags.webui

	depends_on = [ null_resource.provisioner ]
}

# Edge Endpoint Service
resource "consul_agent_service" "edge_service" {
	address = local.node.address
  name = "${var.data.container_name}-edge"
  port = 4566
  tags = var.tags.edge

	depends_on = [ null_resource.provisioner ]
}
