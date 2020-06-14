resource "consul_agent_service" "service" {
  address = local.container_ip_address
	name = var.data.container_name
  port = 8500
  tags = var.tags

	depends_on = [
		null_resource.provisioner
	]
	
}
