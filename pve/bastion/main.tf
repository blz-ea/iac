# Add SSH Keys
resource "digitalocean_ssh_key" "default" {
  name = "Default SSH Key; Managed by Terraform"
  public_key = var.user.ssh_public_key
}

# Provision Droplet
resource "digitalocean_droplet" "bastion" {
  image     = var.bastion.image
  name      = var.bastion.name
  region    = var.bastion.region
  size      = var.bastion.size
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]

  depends_on = [digitalocean_ssh_key.default]
}

resource "null_resource" "initialize" {
	# Provision Container
	provisioner "local-exec" {
		command = "ansible-playbook -i '${digitalocean_droplet.bastion.ipv4_address},' ./bastion/provision.yml -e 'ansible_user=${lookup(var.bastion, "username", "root")}'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True"
		}
	}

  depends_on = [
    digitalocean_droplet.bastion
  ]

}

# Docker containers
module "docker" {
  providers = {
    docker = docker
  }

  source = "./docker"

  cloudflare = var.cloudflare
  bastion = var.bastion
  dependencies = [
    null_resource.initialize.id
  ]
  
}
