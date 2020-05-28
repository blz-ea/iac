terraform {
  required_version = ">= 0.12"
}

locals {
	vars_folder_path = abspath("../vars/")
}

# Import varaibles
module "vars" {
	source = "../modules/terraform/vars"
	# Folder containing variables
	vars_folder = local.vars_folder_path

	# Map of variables, variables will be loaded depending on Terraform's workspace
	# Variables will be merged with default variables
	# If not specified default workspace and default set of variables will be used
	input_var_files = {
		# Workspace name = "file.yml"
		prod = "prod.yml",
	}
}

locals {
  proxmox    = module.vars.workspace.proxmox
  user       = module.vars.workspace.default_user
  domain     = module.vars.workspace.domain
  consul     = module.vars.workspace.consul
  lxc        = module.vars.workspace.lxc
	cloudflare = module.vars.workspace.cloudflare
	bastion 	 = module.vars.workspace.bastion
}

# Provision File Resources
module "proxmox_file" {
	providers = {
		proxmox = proxmox
	}

	source 		= "./file"
}

# Provision DNS Resources
module "dns" {
  providers = {
	  proxmox 		= proxmox
		cloudflare  = cloudflare
  }

  source = "./dns"

  proxmox 			= local.proxmox
	cloudflare 		= local.cloudflare
	bastion 			= local.bastion
	domain 				= local.domain
	user					= local.user
	lxc						= local.lxc
	consul 				= local.consul
	vztmpl 				= module.proxmox_file.vztmpl
}

# Provision Proxmox LXC Containers
module "proxmox_lxc" {
	providers = {
		proxmox 	= proxmox
		consul 		= consul
	}

	user 				= local.user
	proxmox 		= local.proxmox
	lxc 				= local.lxc
	domain 			= local.domain
	consul 			= local.consul
	vztmpl 			= module.proxmox_file.vztmpl
	cloudflare  = local.cloudflare

	dependencies = [
		# module.dns.bind_server_id
	]

	source = "./lxc"
}

# Provision Proxmox Virtual Machines
module "proxmox_vm" {
	providers = {
		proxmox = proxmox
	}

	user 		= local.user
	domain 	= local.domain
	iso 		= module.proxmox_file.iso
	
	source = "./vm"
}

# Provision Proxmox pools
module "proxmox_pool" {
	providers = {
		proxmox = proxmox
	}
	source = "./pool"
}

# Provision Time Settings
module "proxmox_time" {
	providers = {
		proxmox = proxmox
	}
	
	proxmox = local.proxmox
	source 	= "./time"
}

# Providion Bastion Host
module "bastion" {
	providers = {
		digitalocean 	= digitalocean
		cloudflare 		= cloudflare
	}
	cloudflare 	= local.cloudflare
	bastion 		= local.bastion
	user 				= local.user
	source 			= "./bastion"
}
