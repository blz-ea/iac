# Home Assistant module #

Terraform module for setting up [Home Assistant](https://github.com/home-assistant/core) an open source home automation inside LXC container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_home_assistant" {

  providers = {
    proxmox = proxmox
  }

  user      = var.user
  proxmox   = var.proxmox
  domain    = var.domain
  vztmpl    = var.vztmpl
  consul    = var.consul
  data      = {
    node_name: <proxmox_node_name>,
    container_name: "hass",
    hostname: "hass.example.com",
    cert_resolver: <dns_challenge_cert_resolver>,
    memory: {
      dedicated: 2048,
      swap: 1024,
    },
    mounts: [
      "/mnt/lxc/hass/root/.homeassistant/:/root/.homeassistant/",
    ]
  }

  source  = "../../modules/terraform/proxmox/lxc_home_assistant"

  dependencies = [
    module.lxc_consul.provisioner_id
  ]

  # Consul Agent tags
  # Expose Home Assistant Web UI via Traefik
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.hass.entryPoints=https",
    "traefik.http.routers.hass.rule=Host(`hass.example.com`)",
    "traefik.http.routers.hass.tls.certResolver=<dns_challenge_cert_resolver>",
    "traefik.http.routers.hass.service=hass@consulcatalog",
  ]
}
```

## References ##

- [https://github.com/home-assistant/core](https://github.com/home-assistant/core)
