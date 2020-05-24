
module "drone" {

  dependencies = var.dependencies
  container_name = local.drone_container_name

  labels = [
    # Dashboard route
    "traefik.http.routers.${local.drone_container_name}.entryPoints=https",
    "traefik.http.routers.${local.drone_container_name}.rule=Host(`${local.drone_namespace.hostname}`)",
    "traefik.http.routers.${local.drone_container_name}.tls.certResolver=cloudflare",
    "traefik.http.routers.${local.drone_container_name}.service=${local.drone_container_name}",
    "traefik.http.services.${local.drone_container_name}.loadbalancer.server.port=80",
  ]

  env = [
    "DRONE_RPC_SECRET=${local.drone_namespace.rpc_secret}",
    "DRONE_GITHUB_SERVER=https://github.com",
    "DRONE_GITHUB_CLIENT_ID=${local.drone_namespace.github_client_id}",
    "DRONE_GITHUB_CLIENT_SECRET=${local.drone_namespace.github_client_secret}",
    "DRONE_GIT_ALWAYS_AUTH=false",
    "DRONE_RUNNER_CAPACITY=2",
    "DRONE_SERVER_HOST=${local.drone_namespace.hostname}",
    "DRONE_SERVER_PROTO=https",
    "DRONE_LOGS_DEBUG=true",
    "DRONE_USER_FILTER=${local.drone_namespace.user_filter}",
    "DRONE_ADMIN=${local.drone_namespace.user_filter}",
    "DRONE_USER_CREATE=username:${local.drone_namespace.user_admin},admin:true",
  ]

  source = "../../../modules/terraform/docker/drone"
}
