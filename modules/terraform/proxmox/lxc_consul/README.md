# Consul Server module #

Terraform module for setting up [Consul Server](https://github.com/hashicorp/consul) distributed, highly available, and data center aware solution to connect and configure applications across dynamic, distributed infrastructure inside LXC container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_consul" {

  providers = {
    proxmox = proxmox
  }

  user      = var.user
  proxmox   = var.proxmox
  domain    = var.domain
  vztmpl    = var.vztmpl
  consul    = var.consul
  data      = {
    container_name: "consul",
    hostname: "consul.example.com",
    cert_resolver: <dns_challenge_cert_resolver>,
    node_name: <proxmox_node_name>,
    memory: {
      dedicated: 2048,
      swap: 1024,
    },
    network: {
      name: "eth0",
      mac_address: "<mac_address>",
    },
    ip_config: {
      ipv4: {
        address: "<static_ip>/<subnet>",
        gateway: "<default_gateway>",
      }
    },
    mounts: [
      "/mnt/lxc/var/consul/:/var/consul",
    ],
  }

  source    = "../../modules/terraform/proxmox/lxc_consul"

  tags = [
    "traefik.enable=true",
    "traefik.http.routers.consul_server.entryPoints=https",
    "traefik.http.routers.consul_server.rule=Host(`consul.example.com`)",
    "traefik.http.routers.consul_server.tls.certResolver=<dns_challenge_cert_resolver>",
    "traefik.http.routers.consul_server.service=consul_server@consulcatalog",
  ]

}
```

## References ##

- [https://github.com/hashicorp/consul](https://github.com/hashicorp/consul)
