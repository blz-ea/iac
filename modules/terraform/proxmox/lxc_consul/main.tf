locals {
  id = proxmox_virtual_environment_container.container.id
  node_hostname = var.proxmox.nodes.pve.ssh.hostname
  node_username = var.proxmox.nodes.pve.ssh.username
  node_name = var.proxmox.nodes.pve.name
  container_name = var.data.container_name
  container_ip_address = split("/", var.data.ip_config.ipv4.address)[0]
}

resource "null_resource" "depends_on" {
  triggers = {
    depends_on = "${join("", var.dependencies)}"
  }
}

resource "proxmox_virtual_environment_container" "container" {
	description = "Managed by Terraform"
	node_name = var.data.node_name
	started = true

	cpu {
		cores = 6
	}

	initialization {

		dns {
			domain = var.domain.name
			server = var.domain.dns_servers[0]
		}

		hostname = var.data.hostname

		ip_config {
			ipv4 {
				address = var.data.ip_config.ipv4.address
				gateway = var.data.ip_config.ipv4.gateway
			}
		}

		user_account {
			keys     = ["${trimspace(var.user.ssh_public_key)}"]
			password = var.user.password
		}

	}

	memory {
		dedicated = var.data.memory.dedicated
		swap = var.data.memory.swap
	}

	network_interface {
		name = var.data.network.name
		mac_address = var.data.network.mac_address
	}

	operating_system {
		template_file_id = var.vztmpl.ubuntu-18-04-standard-18-04-1-1-amd64.id
		type = "ubuntu"
	}

	depends_on = [
		null_resource.depends_on
	]

}

# Add additional configuration to container from Proxmox node
resource "null_resource" "append" {
	provisioner "local-exec" {
		command = "ansible-playbook -i '${local.node_hostname},' ../modules/ansible-roles/proxmox_lxc_config/tasks/main.yml -e 'ansible_user=${local.node_username}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True",
			TERRAFORM_CONFIG 			= yamlencode({
				container_name 					= local.container_name
				container_id  					= proxmox_virtual_environment_container.container.id
				container_mounts				= lookup(var.data, "mounts", [])
			}),
		}
	}

	triggers = {
		mounts = yamlencode(lookup(var.data, "mounts", []))
	}
	
	depends_on = [
		proxmox_virtual_environment_container.container
	]

}

# Provision Container
resource "null_resource" "provisioner" {
	provisioner "local-exec" {
		command = "ansible-playbook -i '${local.container_ip_address},' ${path.module}/provision.yml -e 'ansible_user=${lookup(var.data, "username", "root")}'"
		environment = {
			ANSIBLE_CONFIG 				= "../ansible.cfg",
			ANSIBLE_FORCE_COLOR 	= "True"
			TERRAFORM_CONFIG 			= yamlencode({
				domain = var.domain
				consul = var.consul
			})
		}
	}
	
	provisioner "local-exec" {
    command = "sleep 5"
  }

	triggers = {
    container_id 					= proxmox_virtual_environment_container.container.id
		consul								= yamlencode(var.consul)
		domain								= yamlencode(var.domain)
		provisioner						= sha1(file("${path.module}/provision.yml"))
  }
	
	depends_on = [
		null_resource.append
	]

}
