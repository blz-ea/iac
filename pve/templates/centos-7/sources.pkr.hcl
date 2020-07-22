source "proxmox" "centos" {
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

	ssh_username 			= var.vm_username
	ssh_password 			= var.vm_user_password
	ssh_timeout				= "30m"
	
	iso_file 				= var.vm_iso_file
	onboot					= true
	
	template_name 		 	= var.template_name
	template_description 	= var.template_description
	unmount_iso 		 	= true

	http_directory 			= "./templates/centos-7/http"
	boot_wait						= "10s"
	boot_command = [
		"<esc><wait><wait><wait><wait>",
		"linux ks=http://{{.HTTPIP}}:{{.HTTPPort}}/preseed.cfg",
		" USERNAME=${var.vm_username}",
		" PASSWORD=${var.vm_user_password}",
		" TIME_ZONE=${var.vm_time_zone}",
		" network --device=eth0 --bootproto=dhcp --onboot=yes --activate",
		"<wait><wait><wait><enter>",
	]
}

build {
	sources = [
		"source.proxmox.centos"
	]

	provisioner "shell" {
		# only = ["centos"]
		inline = [
			"sleep 30",
			"sudo yum -y install cloud-init",
			"exit 0",
		]
	}
}