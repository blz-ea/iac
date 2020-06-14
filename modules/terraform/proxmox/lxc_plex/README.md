# Plex module #

Terraform module for setting up [Plex](https://plex.tv/) client–server media player system inside LXC container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_plex" {

  providers = {
    proxmox = proxmox
  }

  user      = var.user
  proxmox   = var.proxmox
  domain    = var.domain
  vztmpl    = var.vztmpl
  consul    = var.consul
  data      = {
    node_name: "pve",
    container_name: plex,
    hostname: "plex.example.com",
    memory: {
      dedicated: 4096,
      swap: 1024,
    },
    cert_resolver: <dns_challenge_cert_resolver>,
    mounts: [
      "/mnt/lxc/plex:/var/lib/plexmediaserver/",
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
    provisioner: {
      # Username and password is used to claim Newly created server
      # if /var/lib/plexmediaserver contains data from previous installation
      # claiming process is skipped
      plex_username: <plex.tv_email_address>,
      plex_password: <plex.tv_password>,
      plex_server_name: <plex_server_friendly name>,
    }
  }

  source    = "../../modules/terraform/proxmox/lxc_plex"

  dependencies = [
    module.lxc_consul.provisioner_id
  ]

  # Consul Agent Tags
  # Expose Plex via Traefik
  tags = [
    "traefik.enable=true",
    "traefik.http.routers.lxc_plex.entryPoints=https",
    "traefik.http.routers.lxc_plex.rule=Host(`plex.example.com`)",
    "traefik.http.routers.lxc_plex.tls.certResolver=<dns_challenge_cert_resolver>",
    "traefik.http.routers.lxc_plex.service=lxc_plex@consulcatalog",
  ]
}
```

## References ##

- [https://support.plex.tv/articles/](https://support.plex.tv/articles/)
