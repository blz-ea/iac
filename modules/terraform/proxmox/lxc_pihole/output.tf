output "provisioner_id" {
	value = null_resource.provisioner.id
}

output "ip_address" {
	value = local.node.address
}
