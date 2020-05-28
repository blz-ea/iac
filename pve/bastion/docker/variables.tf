variable "dependencies" {
  type = any
}

variable "cloudflare" {
  type = any
}

variable "bastion" {
  type = any
}

locals {
  # Traefik local variables
  traefik_namespace       = var.bastion.docker.traefik
  traefik_container_name  = lookup(local.traefik_namespace, "name", "traefik_container")
  default_auth            = join(",", local.traefik_namespace.default_auth)

  # Drone local variables
  drone_namespace       = var.bastion.docker.drone
  drone_container_name  = lookup(local.drone_namespace, "name", "drone_container")
  
  # Registry local variables
  registry_namespace       = var.bastion.docker.registry
  registry_container_name = lookup(local.registry_namespace, "name", "registry_container")
}