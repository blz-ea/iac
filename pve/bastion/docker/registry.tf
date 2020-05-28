module "registry" {

  dependencies = var.dependencies

  env = []
  ports = [
    "5000:5000"
  ]

  labels = [
    "traefik.enable=true",
    "traefik.http.routers.${local.registry_container_name}.entryPoints=https",
    "traefik.http.routers.${local.registry_container_name}.rule=Host(`${local.registry_namespace.hostname}`)",
    "traefik.http.routers.${local.registry_container_name}.tls.certResolver=cloudflare",
    "traefik.http.routers.${local.registry_container_name}.service=${local.registry_container_name}",
    "traefik.http.routers.${local.registry_container_name}.middlewares=default-basic-auth",
    "traefik.http.services.${local.registry_container_name}.loadbalancer.server.port=5000",
  ]

  source = "../../../modules/terraform/docker/registry"
}