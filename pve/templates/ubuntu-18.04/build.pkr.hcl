locals {
	template = local.workspace.packer.ubuntu.bionic
}
source "proxmox" "ubuntu" {
	proxmox_url =  "${local.workspace.proxmox.nodes.pve.auth.api_url}/api2/json"
	insecure_skip_tls_verify = local.workspace.proxmox.nodes.pve.auth.tls_insecure
	username = local.workspace.proxmox.nodes.pve.auth.username
	password = local.workspace.proxmox.nodes.pve.auth.password
	node = local.workspace.proxmox.nodes.pve.name
	
	vm_name = local.template.name
	vm_id = local.template.id
	
	memory = local.template.memory
	sockets = local.template.sockets
	cores = local.template.cores
	os = local.template.os

	network_adapters {
		model = "virtio"
		bridge = "vmbr0"
	}

	qemu_agent = true
	scsi_controller = local.template.scsi_controller

	disks {
		type = local.template.disk[0].type
		disk_size = local.template.disk[0].disk_size
		storage_pool = local.template.disk[0].storage_pool
		storage_pool_type = local.template.disk[0].storage_pool_type
		format = local.template.disk[0].format
	}

	ssh_username = local.workspace.default_user.name
	ssh_password = local.workspace.default_user.password
	ssh_timeout= "30m"
	
	iso_file = local.template.iso_file
	
	template_name = local.template.name
	template_description = local.template.description
	unmount_iso = true
   
	
	http_directory = "./templates/ubuntu-18.04/http"
	boot_wait= "10s"
	boot_command = [
		"<esc><wait>",
		"<esc><wait>",
		"<enter><wait>",
		"/install/vmlinuz initrd=/install/initrd.gz",
		" auto=true priority=critical interface=auto",
		" netcfg/dhcp_timeout=120",
		" hostname=${local.template.name}",
		" username=${local.workspace.default_user.name}",
		" time_zone=${local.template.time_zone}",
		" passwd/username=${local.workspace.default_user.name}",
		" passwd/user-fullname=${local.workspace.default_user.name}",
		" passwd/user-password=${local.workspace.default_user.password}",
		" passwd/user-password-again=${local.workspace.default_user.password}",
		" preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
		" <enter>"
	]
}

build {
	sources = [
		"source.proxmox.ubuntu"
	]

	provisioner "shell" {
		# only = ["ubuntu"]  # <- not supported yet https://github.com/hashicorp/packer/issues/9094
		# pause_before = "20s" # Not supported at the moment
		environment_vars = [
			"DEBIAN_FRONTEND=noninteractive",
		]
		inline = [
			"sleep 30",
			"sudo apt-get update",
			"sudo apt-get -y upgrade",
			"sudo apt-get -y dist-upgrade",
			"sudo apt-get -y install linux-generic linux-headers-generic linux-image-generic",
			"sudo apt-get -y install qemu-guest-agent cloud-init",
			"sudo apt-get -y install wget curl",
			# DHCP Server assigns same IP address if machine-id is preserved, new machine-id will be generated on first boot
			"sudo truncate -s 0 /etc/machine-id",
			"exit 0"
		]
	}
}

