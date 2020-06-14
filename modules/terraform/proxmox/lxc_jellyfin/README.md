# Jellyfin module #

Terraform module for setting up [Jellyfin](https://github.com/jellyfin/jellyfin) a fully functional local AWS cloud stack inside LXC container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_jellyfin" {

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
    container_name: "jellyfin",
    hostname: "jellyfin.example.com",
    cert_resolver: <dns_challenge_cert_resolver>,
    memory: {
      dedicated: 4096,
      swap: 1024,
    },
    mounts: [
      "/mnt/lxc/jellyfin/lib:/var/lib/jellyfin/",
      "/mnt/lxc/jellyfin/etc:/etc/jellyfin",
      "/mnt/lxc/jellyfin/cache:/var/cache/jellyfin",
      "/mnt/library/share/:/mnt/local",
    ],
    features: "fuse=1,mount=nfs",
    lxc_cfg: [
      "lxc.autodev: 1",
      # Allow video groups to be accessed from the container
      "lxc.cgroup.devices.allow: c 195:* rwm",
      "lxc.cgroup.devices.allow: c 236:* rwm",
      "lxc.cgroup.devices.allow: c 226:* rwm",
      # Mount video devices
      "lxc.mount.entry: /dev/dri/card0 /dev/dri/card0 none bind,optional,create=file",
      "lxc.mount.entry: /dev/dri/renderD128 /dev/dri/renderD128 none bind,optional,create=file",
    ],
  }

  source    = "../../modules/terraform/proxmox/lxc_jellyfin"

  dependencies = [
    module.lxc_consul.provisioner_id
  ]

  # Consul Agent tags
  # Expose Jellyfin Web UI via Traefik
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.lxc_jellyfin.entryPoints=https",
    "traefik.http.routers.lxc_jellyfin.rule=Host(`jellyfin.example.com`)",
    "traefik.http.routers.lxc_jellyfin.tls.certResolver=<dns_challenge_cert_resolver>",
    "traefik.http.routers.lxc_jellyfin.service=lxc_jellyfin@consulcatalog",
  ]
}
```

## References ##

- [https://github.com/jellyfin/jellyfin](https://github.com/jellyfin/jellyfin)
