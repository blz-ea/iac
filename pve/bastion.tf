#############################################################
# Bastion Droplet
#############################################################
provider "docker" {
  host = "ssh://${var.user_name}@${digitalocean_droplet.bastion.ipv4_address}:${var.bastion_ssh_port}"
}

# Add SSH Key to Digital Ocean account
resource "digitalocean_ssh_key" "default" {
  name = "Default SSH Key; Managed by Terraform"
  public_key = trimspace(file(pathexpand(var.user_ssh_public_key_location)))
}

# Provision Droplet
resource "digitalocean_droplet" "bastion" {
  image     = var.bastion_image
  name      = var.bastion_hostname
  region    = var.bastion_region
  size      = var.bastion_size

  ssh_keys  = [
    digitalocean_ssh_key.default.fingerprint
  ]

  depends_on = [
    digitalocean_ssh_key.default
  ]
}

# Provision Droplet
resource "null_resource" "bastion_initialize" {
    # TODO: Add Triggers and separate into two separate provisioners
	provisioner "local-exec" {
		command = "ansible-playbook -i '${digitalocean_droplet.bastion.ipv4_address},' ${path.module}/bastion/bastion_provision.yml -e 'ansible_user=root'"
		environment = {
			ANSIBLE_CONFIG = "../ansible.cfg",
			ANSIBLE_FORCE_COLOR = "True",
			TERRAFORM_CONFIG = yamlencode({
              user_name = var.user_name,
              user_password = var.user_password,

              bastion_ssh_port = var.bastion_ssh_port
              # List of authorized keys
              bastion_user_authorized_keys = [
                {
                  path = var.bastion_ssh_public_key_location,
                  state = "present",
                },
              ],
              # Bastion host firewall rules
              ufw_rules = [
                { rule = "allow", port = "80", proto = "tcp" },
                { rule = "allow", port = "443", proto = "tcp" },
              ],
			}),
		}
	}

  depends_on = [
    digitalocean_droplet.bastion
  ]

}

#############################################################
# Bastion Drone CI Container
#############################################################
module "bastion_drone_server" {
  dependencies = [
    null_resource.bastion_initialize.id
  ]

  container_name = "drone"

  labels = [
    "traefik.enable=true",
    "traefik.http.routers.drone.entryPoints=https",
    "traefik.http.routers.drone.rule=Host(`drone.bs.${var.domain_name}`)",
    "traefik.http.routers.drone.tls.certResolver=cloudflare",
    "traefik.http.routers.drone.service=drone",
    "traefik.http.services.drone.loadbalancer.server.port=80",
  ]

  env = [
    "DRONE_RPC_SECRET=${var.bastion_drone_server_rpc_secret}",
    "DRONE_GITHUB_SERVER=https://github.com",
    "DRONE_GITHUB_CLIENT_ID=${var.bastion_drone_server_github_client_id}",
    "DRONE_GITHUB_CLIENT_SECRET=${var.bastion_drone_server_github_client_secret}",
    "DRONE_GIT_ALWAYS_AUTH=false",
    "DRONE_RUNNER_CAPACITY=2",
    "DRONE_SERVER_HOST=drone.bs.${var.domain_name}",
    "DRONE_SERVER_PROTO=https",
    "DRONE_LOGS_DEBUG=true",
    "DRONE_USER_FILTER=${var.bastion_drone_server_user_filter}",
    "DRONE_ADMIN=${var.bastion_drone_server_user_filter}",
    var.bastion_drone_server_user_admin == "" ? "" : "DRONE_USER_CREATE=username:${var.bastion_drone_server_user_admin},admin:true",
  ]

  source = "../modules/terraform/docker/drone"
}

#############################################################
# Docker registry
#############################################################
module "bastion_registry" {
  dependencies = [
    null_resource.bastion_initialize.id
  ]

  env = []
  ports = [
    "5000:5000"
  ]

  labels = [
    "traefik.enable=true",
    "traefik.http.routers.registry.entryPoints=https",
    "traefik.http.routers.registry.rule=Host(`registry.bs.${var.domain_name}`)",
    "traefik.http.routers.registry.tls.certResolver=cloudflare",
    "traefik.http.routers.registry.service=registry",
    "traefik.http.routers.registry.middlewares=default-basic-auth",
    "traefik.http.services.registry.loadbalancer.server.port=5000",
  ]

  source = "../modules/terraform/docker/registry"
}

#############################################################
# Traefik
#############################################################
module "bastion_traefik" {
  dependencies = [
    null_resource.bastion_initialize.id
  ]

  container_name = "traefik"

  ports = [
    "80:80",
    "443:443",
  ]

  command = [
    "--entryPoints.http.address=:80",
    "--entryPoints.https.address=:443",

    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",

    "--providers.file=true",
    "--providers.file.directory=/etc/conf.d/",

    "--certificatesResolvers.cloudflare.acme.email=${var.cloudflare_account_email}",
    "--certificatesResolvers.cloudflare.acme.storage=/letsencrypt/acme.json",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=30",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53",
  ]

  labels = [
    # Default Auth
    # TODO: Add Authlia
    "traefik.http.middlewares.default-basic-auth.basicauth.users=${join(",", var.bastion_traefik_container_basic_auth)}",
    # Dashboard route
    "traefik.http.routers.traefik.entryPoints=https",
    "traefik.http.routers.traefik.rule=Host(`traefik.bs.${var.domain_name}`)",
    "traefik.http.routers.traefik.tls.certResolver=cloudflare",
    "traefik.http.routers.traefik.service=api@internal",
    "traefik.http.routers.traefik.middlewares=default-basic-auth",
  ]

  file_cfg = var.bastion_traefik_container_file_cfg

  env = [
    "CLOUDFLARE_EMAIL=${var.cloudflare_account_email}",
    "CLOUDFLARE_ZONE_API_TOKEN=${var.cloudflare_api_token}",
    "CLOUDFLARE_DNS_API_TOKEN=${var.cloudflare_api_token}"
  ]

  networks_advanced = var.bastion_traefik_container_network_advanced

  source = "../modules/terraform/docker/traefik"
}
