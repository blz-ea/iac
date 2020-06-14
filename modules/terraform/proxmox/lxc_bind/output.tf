output "provisioner_id" {
	value = null_resource.provisioner.id
}

output "ip_address" {
	value = local.container_ip_address
}
