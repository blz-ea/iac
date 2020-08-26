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
    digitalocean_ssh_key.default,
  ]
}

# Run initialize provisioner
resource "null_resource" "bastion_initialize" {
  provisioner "local-exec" {
    command = "ansible-playbook -i '${digitalocean_droplet.bastion.ipv4_address},' ${path.module}/bastion_initialize.yml -e 'ansible_user=root'"
    environment = {
      ANSIBLE_CONFIG = "../ansible.cfg",
      ANSIBLE_FORCE_COLOR = "True",
      TERRAFORM_CONFIG = yamlencode({
        user_name = var.user_name,
        user_password = var.user_password,

        bastion_ssh_port = var.bastion_ssh_port
        # List of authorized keys for deploy user
        bastion_user_authorized_keys = [
          {
            path = var.bastion_ssh_public_key_location,
            state = "present",
          },
        ],
      }),
    }
  }

  depends_on = [
    digitalocean_droplet.bastion,
  ]

}

# Provision droplet
resource "null_resource" "bastion_provision" {
  provisioner "local-exec" {
    command = "ansible-playbook -i '${digitalocean_droplet.bastion.ipv4_address},' ${path.module}/bastion_provision.yml -e 'ansible_user=${var.user_name}'  -e 'ansible_port=${var.bastion_ssh_port}'"
    environment = {
      ANSIBLE_CONFIG = "../ansible.cfg",
      ANSIBLE_FORCE_COLOR = "True",
      TERRAFORM_CONFIG = yamlencode({
        user_name = var.user_name,
      }),
    }
  }

  depends_on = [
    null_resource.bastion_initialize,
  ]

}

locals {
  bastion_ufw_rules = [
    { rule = "allow", port = "80", proto = "tcp" },
    { rule = "allow", port = "443", proto = "tcp" },
    { rule = "allow", port = "8080", proto = "tcp", interface = "docker0", direction = "in" }, # Frp proxy
    { rule = "allow", port = "43500", proto = "tcp" }, # Frp proxy
    { rule = "allow", port = "60000:61000", proto = "udp" }, # Mosh
  ]
}

# Provision droplet - fw
resource "null_resource" "bastion_provision_fw" {
  triggers = {
    ufw_rules = sha1(yamlencode(local.bastion_ufw_rules))
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i '${digitalocean_droplet.bastion.ipv4_address},' ${path.module}/bastion_fw.yml -e 'ansible_user=${var.user_name}'  -e 'ansible_port=${var.bastion_ssh_port}'"
    environment = {
      ANSIBLE_CONFIG = "../ansible.cfg",
      ANSIBLE_FORCE_COLOR = "True",
      TERRAFORM_CONFIG = yamlencode({
        # Bastion host firewall rules
        ufw_rules = local.bastion_ufw_rules
      }),
    }
  }

  depends_on = [
    null_resource.bastion_initialize,
  ]

}

#############################################################
# Frp proxy service
#############################################################
resource "null_resource" "bastion_frp_proxy" {
  triggers = {
    ipv4_address  = digitalocean_droplet.bastion.ipv4_address
    username      = var.user_name
    ssh_port      = var.bastion_ssh_port
    frp_bind_port = var.bastion_service_frp_bind_port
    frp_token     = var.bastion_service_frp_token
    frp_vhost_http_port = var.bastion_service_frp_vhost_http_port
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.triggers.ipv4_address},' ../modules/ansible-roles/main.yml -e 'ansible_user=${self.triggers.username}' -e 'ansible_port=${self.triggers.ssh_port}'  -e 'state=present' --tags frp"
    environment = {
      ANSIBLE_CONFIG = "../ansible.cfg",
      ANSIBLE_FORCE_COLOR = "True",

      FRP_BIND_PORT = var.bastion_service_frp_bind_port
      FRP_TOKEN = var.bastion_service_frp_token
      FRP_VHOST_HTTP_PORT = var.bastion_service_frp_vhost_http_port
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "ansible-playbook -i '${self.triggers.ipv4_address},' ../modules/ansible-roles/main.yml -e 'ansible_user=${self.triggers.username}' -e 'ansible_port=${self.triggers.ssh_port}' -e 'state=absent' --tags frp"
    environment = {
      ANSIBLE_CONFIG = "../ansible.cfg",
      ANSIBLE_FORCE_COLOR = "True",
    }
  }

  depends_on = [
    null_resource.bastion_provision,
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

  file_cfg_dynamic = var.bastion_traefik_container_file_cfg_dynamic
  file_cfg_static = var.bastion_traefik_container_file_cfg_static

  env = [
    "CLOUDFLARE_EMAIL=${var.cloudflare_account_email}",
    "CLOUDFLARE_ZONE_API_TOKEN=${var.cloudflare_api_token}",
    "CLOUDFLARE_DNS_API_TOKEN=${var.cloudflare_api_token}"
  ]

  networks_advanced = var.bastion_traefik_container_network_advanced

  source = "../modules/terraform/docker/traefik"
}
