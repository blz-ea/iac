# Traefik module #

Terraform module for setting up [Traefik](https://github.com/containous/traefik/) reverse proxy inside LXC container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_traefik" {

  providers = {
    proxmox = proxmox
  }

  user = var.user
  proxmox = var.proxmox
  domain = var.domain
  vztmpl = var.vztmpl
  consul = var.consul

  data = {
    hostname: "traefik.example.com",
    container_name: "traefik",
    node_name: <proxmox_node_name>,
    memory: {
      dedicated: 2048,
      swap: 1024,
    },
    mounts: [
      "/mnt/lxc/traefik:/opt/traefik",
    ],
  }

  source = "../../modules/terraform/proxmox/lxc_traefik"

  environment = [
    "CLOUDFLARE_API_KEY=<cloudflare_api_key>",
    "CLOUDFLARE_EMAIL=<cloudflare_email>",
  ]

  cli_options = [
    "--entryPoints.http.address=:80",
    "--entryPoints.https.address=:443",

    # Consul Catalog provider for dynamic configuration
    "--providers.consulcatalog=true",
    "--providers.consulcatalog.exposedByDefault=false",
    "--providers.consulcatalog.prefix=traefik",
    "--providers.consulcatalog.endpoint.scheme=<consul_scheme>",
    "--providers.consulcatalog.endpoint.tls.insecureSkipVerify=true",
    "--providers.consulcatalog.endpoint.datacenter=<consul_datacenter>",
    "--providers.consulcatalog.endpoint.address=<consul_host>:<consul_port>",
    "--providers.consulcatalog.endpoint.httpAuth.username=<consul_username>",
    "--providers.consulcatalog.endpoint.httpAuth.password=<consul_password>",

    # Consul KV Store provider for dynamic configuration
    "--providers.consul=true",
    "--providers.consul.rootkey=traefik",
    "--providers.consul.tls.insecureSkipVerify=true",
    "--providers.consul.username=<consul_username>",
    "--providers.consul.password=<consul_password>",
    "--providers.consul.endpoints=<consul_scheme>://<consul_host>:<consul_port>",

    "--certificatesResolvers.cloudflare.acme.email=<cloudflare_email>",
    "--certificatesResolvers.cloudflare.acme.storage=/opt/traefik/acme.json",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.provider=cloudflare",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.delayBeforeCheck=30",
    "--certificatesResolvers.cloudflare.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53",
  ]

  dynamic_config = [
    # Enables Traefik dashboard
    "traefik.enable=true",
    "traefik.http.routers.<name>.entryPoints=https",
    "traefik.http.routers.<name>.rule=Host(`traefik.example.com`)",
    "traefik.http.routers.<name>.tls.certResolver=cloudflare",
    "traefik.http.routers.<name>.service=api@internal",
  ]

  # List of dependencies
  dependencies = [
    module.lxc_consul.provisioner_id
  ]
}
```

## References ##

- [https://docs.traefik.io/](https://docs.traefik.io/)
