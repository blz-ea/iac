data "consul_nodes" "nodes" {
  query_options {
	# Last bit creates hacky dependency, `depends_on` always triggers data source read
    datacenter = "${var.consul.default.data_center}${replace(null_resource.consul_agent.id, "/.*/", "")}"
  }
}

locals {
	node = [ for node in data.consul_nodes.nodes.nodes: node if node.name == local.container_name ][0]
	root_key = lookup(var.data, "root_key", "traefik")
}

# Traefik Dynamic configuration
resource "consul_agent_service" "service" {
	address = local.node.address
  	name = var.data.container_name
  	tags = var.dynamic_config

	depends_on = [ null_resource.provisioner ]
}

# Create prefix key
resource "consul_keys" "traefik" {
	datacenter = var.consul.default.data_center
	
	key {
		path  = "${local.root_key}/"
		delete = true
	}

	depends_on = [ null_resource.provisioner ]
}

# Creates global http to https middleware
# Every request will be redirected to https
resource "consul_keys" "global-http-to-https-redirect" {
	datacenter = var.consul.default.data_center
		
	key {
		path  = "${local.root_key}/http/middlewares/https-redirect/redirectScheme/scheme"
		value = "https"
		delete = true
	}

	key {
		path  = "${local.root_key}/http/routers/redirect/entryPoints/0"
		value = "http"
		delete = true
	}
  
	key {
		path  = "${local.root_key}/http/routers/redirect/rule"
		value = "hostregexp(`{host:.+}`)"
		delete = true
	}

	key {
		path  = "${local.root_key}/http/routers/redirect/middlewares/0"
		value = "https-redirect"
		delete = true
	}

	key {
		path  = "${local.root_key}/http/routers/redirect/service"
		value = "noop@internal"
		delete = true
	}

	key {
		path  = "${local.root_key}/http/routers/redirect/priority"
		value = 1
		delete = true
	}

	depends_on = [ null_resource.provisioner ]
}