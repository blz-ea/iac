# Pi-hole module #

Terraform module for setting up [Pi-hole](https://github.com/pi-hole/pi-hole/) a DNS sinkhole inside LXC Container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_pihole" {
  providers = {
    proxmox = proxmox
  }

  user      = var.user
  proxmox   = var.proxmox
  domain    = var.domain
  vztmpl    = var.vztmpl

  data      = {
    hostname: "pihole.example.com",
    container_name: "pihole",
    node_name: "pve",
    memory: {
      dedicated: 2048,
      swap: 1024,
    },
    cert_resolver: <dns_challenge_cert_resolver>
    provisioner: {
      conditional_forwarding: true,
      conditional_forwarding_ip: "192.168.88.1",
      conditional_forwarding_domain: devset.app,
      conditional_forwarding_reverse: 88.168.192.in-addr.arpa,
      network: {
        dns_servers: [
          "192.168.88.1#53",
        ]
      },
      webui_password: <some_password>,
    },
  }

  consul    = var.consul

  source    = "../../modules/terraform/proxmox/lxc_pihole"

  dependencies = [
    module.lxc_consul.provisioner_id
  ]

  # Consul Agent tags
  # Expose Pihole Web UI via Traefik
  tags = [
    "traefik.enable=true",
    "traefik.http.middlewares.pihole-replace-prefix.replacePathRegex.regex=^/(.*)",
    "traefik.http.middlewares.pihole-replace-prefix.replacePathRegex.replacement=/admin/$1",

    "traefik.http.routers.lxc_pihole.entryPoints=https",
    "traefik.http.routers.lxc_pihole.rule=Host(`pihole.example.com`)",
    "traefik.http.routers.lxc_pihole.middlewares=pihole-replace-prefix",
    "traefik.http.routers.lxc_pihole.tls.certResolver=<dns_challenge_cert_resolver>",
    "traefik.http.routers.lxc_pihole.service=lxc_pihole@consulcatalog",
  ]
}
```

## References ##

- [https://docs.pi-hole.net/](https://docs.pi-hole.net/)
