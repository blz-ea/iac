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
			server = var.domain.dns_servers[0]
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
		template_file_id = var.vztmpl.ubuntu-18-04-standard-18-04-1-1-amd64.id
		type = "ubuntu"
	}

	# Add Container's IP address to KV store
	provisioner "local-exec" {
		command = "ansible-playbook -i ${local.node_hostname}, ../modules/ansible-roles/proxmox_lxc_register/tasks/main.yml -e 'ansible_user=${local.node_username}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True",
			TERRAFORM_CONFIG 			= yamlencode({
				pve_node 			= var.data.node_name
				consul			  = var.consul
				container_id  = proxmox_virtual_environment_container.container.id
			}),
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
				container_features			= lookup(var.data, "features", "")
				container_lxc_cfg				= lookup(var.data, "lxc_cfg", [])
			}),
		}
	}

	triggers = {
		mounts  	= yamlencode(lookup(var.data, "mounts", []))
		feature 	= yamlencode(lookup(var.data, "feature", ""))
		lxc_cfg		=	yamlencode(lookup(var.data, "lxc_cfg", []))
	}
	
	depends_on = [
		data.consul_keys.container,
		proxmox_virtual_environment_container.container
	]

}

# Provision Container
resource "null_resource" "provisioner" {
	
	provisioner "local-exec" {
		command = "ansible-playbook -i '${data.consul_keys.container.var.ipv4_address_0},' ${path.module}/provision.yml -e 'ansible_user=${lookup(var.data, "username", "root")}'"
		environment = {
			ANSIBLE_CONFIG 				= "../ansible.cfg",
			ANSIBLE_FORCE_COLOR 	= "True"
			TERRAFORM_CONFIG 			= yamlencode(var.data.provisioner)
		}
	}

	triggers = {
		provisioner_cfg				= yamlencode(var.data.provisioner)
		provisioner						= sha1(file("${path.module}/provision.yml"))
	}

	depends_on = [
		null_resource.append
	]

}

# Provision Container - Consul Agent
resource "null_resource" "consul_agent" {
		
	provisioner "local-exec" {
		command = "ansible-playbook -i '${data.consul_keys.container.var.ipv4_address_0},' ../modules/ansible-roles/consul_agent/tasks/main.yml -e 'ansible_user=${lookup(var.data, "username", "root")}'"
		environment = {
			ANSIBLE_CONFIG 				= "../ansible.cfg",
			ANSIBLE_FORCE_COLOR 	= "True",
			TERRAFORM_CONFIG 			= yamlencode({
				consul = var.consul
			})
		}
	}

	provisioner "local-exec" {
    command = "sleep 5"
  }

	triggers = {
    container_id 			= proxmox_virtual_environment_container.container.id
		provisioner				= sha1(file("../modules/ansible-roles/consul_agent/tasks/main.yml"))
		consul_cfg				= yamlencode(var.consul)
  }

	depends_on = [
		null_resource.provisioner
	]

}