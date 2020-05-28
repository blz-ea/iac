locals {
  id = proxmox_virtual_environment_container.container.id
  node_hostname = var.proxmox.nodes.pve.ssh.hostname
  node_username = var.proxmox.nodes.pve.ssh.username
  node_name = var.proxmox.nodes.pve.name
  container_name = var.data.container_name
  container_ip_address = split("/", var.data.ip_config.ipv4.address)[0]
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

}

resource "null_resource" "provision" {
	# Append Additional Configuration to Container via SSH
	provisioner "local-exec" {
		command = "ansible-playbook -i '${local.node_hostname},' ${path.module}/append.yml -e 'container_name=${local.container_name}' -e 'ansible_user=${local.node_username}' -e 'container_id=${proxmox_virtual_environment_container.container.id}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True"
		}
	}

	# Provision Container
	provisioner "local-exec" {
		command = "ansible-playbook -i '${local.container_ip_address},' ${path.module}/provision.yml -e 'ansible_user=${lookup(var.data, "username", "root")}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True"
		}
	}

  provisioner "local-exec" {
    command = "sleep 15"
  }

}
