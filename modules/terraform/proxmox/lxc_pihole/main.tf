locals {
  id = proxmox_virtual_environment_container.container.id
  node_hostname = var.proxmox.nodes.pve.ssh.hostname
  node_username = var.proxmox.nodes.pve.ssh.username
  node_name = var.proxmox.nodes.pve.name
  container_name = var.data.container_name
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
		hostname = var.data.hostname

		dns {
			domain = var.domain.name
		}

		ip_config {
			ipv4 {
				address = "dhcp"
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
		name = "eth0"
	}

	operating_system {
		template_file_id = var.vztmpl.ubuntu-19-10-standard-19-10-1-amd64.id
		type = "ubuntu"
	}

	# Add Container's IP address to KV store
	provisioner "local-exec" {
		command = "ansible-playbook -i ${local.node_hostname}, ../modules/ansible-roles/lxc_register/tasks/main.yml -e 'ansible_user=${local.node_username}' -e 'pve_node=${local.node_name}' -e 'container_id=${proxmox_virtual_environment_container.container.id}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True"
		}
	}

	depends_on = [
		null_resource.depends_on
	]

}

# Retrive Container's IP address from KV Store
data "consul_keys" "container" {
  datacenter = var.consul.default.data_center

  key {
    name    = "ipv4_address_0"
    path    = "proxmox/${local.node_name}/lxc/${local.id}/ipv4_address/0"
  }
}

resource "null_resource" "provision" {
	# Provision Container
	provisioner "local-exec" {
		command = "ansible-playbook -i '${data.consul_keys.container.var.ipv4_address_0},' ../modules/terraform/lxc_pihole/provision.yml -e 'ansible_user=${lookup(var.data, "username", "root")}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True"
		}
	}

	depends_on = [
		data.consul_keys.container,
		proxmox_virtual_environment_container.container
	]

}