module "traefik" {

  cloudflare = var.cloudflare
  dependencies = var.dependencies
  container_name = local.traefik_container_name

  ports = [
    "80:80",
    "443:443"
  ]

  command = [
    "--entryPoints.http.address=:80",
    "--entryPoints.https.address=:443",

    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",

    "--certificatesResolvers.cloudflare.acme.email=${var.cloudflare.email}",
    "--certificatesResolvers.cloudflare.acme.storage=/letsencrypt/acme.json",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=30",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53",
  ]
  
  labels = [
    # Default Auth
    "traefik.http.middlewares.default-auth.digestauth.users=${local.default_auth}",
    # Dashboard route
    "traefik.http.routers.${local.traefik_container_name}.entryPoints=https",
    "traefik.http.routers.${local.traefik_container_name}.rule=Host(`${local.traefik_namespace.dashboard_hostname}`)",
    "traefik.http.routers.${local.traefik_container_name}.tls.certResolver=cloudflare",
    "traefik.http.routers.${local.traefik_container_name}.service=api@internal",
    "traefik.http.routers.${local.traefik_container_name}.middlewares=default-auth"
  ]

  env = [
    "CLOUDFLARE_EMAIL=${var.cloudflare.email}",
    "CLOUDFLARE_API_KEY=${var.cloudflare.api_key}",
  ]

  source = "../../../modules/terraform/docker/traefik"
}
