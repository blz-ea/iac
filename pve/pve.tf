terraform {
  required_version = ">= 0.12"
}

locals {
	# Variables location folder
	vars_folder_path = abspath("../vars/")
}

# Import varaibles
# Variable file based on current workspace will be preloaded
# If not found file with deault variables will be used
module "vars" {
	source = "../modules/terraform/vars"
	# Folder containing variables
	vars_folder = local.vars_folder_path
	default_vars_file = "default_proxmox.yml"
}

locals {
	workspace  = module.vars.workspace
  proxmox    = module.vars.workspace.proxmox
  user       = module.vars.workspace.default_user
  domain     = module.vars.workspace.domain
  consul     = module.vars.workspace.consul
  lxc        = module.vars.workspace.lxc
	cloudflare = module.vars.workspace.cloudflare
	bastion 	 = module.vars.workspace.bastion
	packer		 = module.vars.workspace.packer 
}

# Provision File Resources
module "proxmox_file" {
	providers = {
		proxmox = proxmox
	}

	source 		= "./file"
}

# Provision Packer Templates
module "proxmox_templates" {
	providers = {
		proxmox = proxmox
	}

	templates = local.packer

	source 		= "./templates"
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

	workspace		= local.workspace
	user 				= local.user
	proxmox 		= local.proxmox
	lxc 				= local.lxc
	domain 			= local.domain
	consul 			= local.consul
	vztmpl 			= module.proxmox_file.vztmpl
	cloudflare  = local.cloudflare

	dependencies = []

	source = "./lxc"
}

# External configuration that needs to be exposed via discovery services
# E.g. internal web uis
module "discovery" {
	providers = {
		consul 		= consul
	}

	consul 			= local.consul
	proxmox			= local.proxmox

	dependencies = [
		# Resource is dependant on Consul Server LXC Container
		module.proxmox_lxc.lxc_consul.provisioner_id
	]

	source = "./discovery"
}

# Provision Proxmox Virtual Machines
module "proxmox_vm" {
	providers = {
		proxmox = proxmox
	}

	user 		= local.user
	domain 	= local.domain
	iso 		= module.proxmox_file.iso

	dependencies = []
	
	source = "./vm"
}

# Providion Bastion Host
# Digital Ocean based Bastion Host
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