source "proxmox" "ubuntu" {
	proxmox_url 				= "${var.proxmox_hostname}/api2/json"
	insecure_skip_tls_verify 	= var.proxmox_insecure_skip_tls_verify
	username 					= var.proxmox_username
	password 					= var.proxmox_password
	node 						= var.proxmox_node
	
	vm_name = var.template_name
	vm_id 	= var.vm_id
	
	memory 	= var.vm_memory
	sockets = var.vm_sockets
	cores 	= var.vm_cores
	os 		= "l26"

	network_adapters {
		model 	= "virtio"
		bridge 	= "vmbr0"
	}

	qemu_agent 			= true
	scsi_controller 	= "virtio-scsi-pci"

	disks {
		type				= "scsi"
		disk_size 			= "30G"
		storage_pool 		= var.vm_storage_pool
		storage_pool_type 	= "lvm-thin"
		format 				= "raw"
	}

	ssh_username 		= var.vm_username
	ssh_password 		= var.vm_user_password
	ssh_timeout			= "30m"
	
	iso_file 			= var.vm_iso_file
	onboot				= true
	
	template_name 		 = var.template_name
	template_description = var.template_description
	unmount_iso 		 = true
   
	
	http_directory = "./templates/ubuntu-18.04/http"
	boot_wait= "10s"
	boot_command = [
		"<esc><wait>",
		"<esc><wait>",
		"<enter><wait>",
		"/install/vmlinuz initrd=/install/initrd.gz",
		" auto=true priority=critical interface=auto",
		" netcfg/dhcp_timeout=120",
		" hostname=${var.template_name}",
		" username=${var.vm_username}",
		" time_zone=${var.vm_time_zone}",
		" passwd/username=${var.vm_username}",
		" passwd/user-fullname=${var.vm_username}",
		" passwd/user-password=${var.vm_user_password}",
		" passwd/user-password-again=${var.vm_user_password}",
		" preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg",
		" <enter>"
	]
}

build {
	sources = [
		"source.proxmox.ubuntu"
	]

	provisioner "shell" {
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

