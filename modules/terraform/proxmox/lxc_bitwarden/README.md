# Bitwarden_rs module #

Terraform module for setting up [Bitwarden_rs](https://github.com/dani-garcia/bitwarden_rs) unofficial Bitwarden compatible server written in Rust inside LXC Container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_bitwarden" {

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
    container_name: "bitwarden",
    hostname: "bitwarden.example.com",
    cert_resolver: <dns_challenge_cert_resolver>,
    memory: {
      dedicated: 2048,
      swap: 1024,
    },
    mounts: [
      "/mnt/lxc/bitwarden/opt/bitwardenrs/:/opt/bitwardenrs",
    ],
    features: "fuse=1,nesting=1",
    lxc_cfg: [
      "lxc.apparmor.profile: unconfined",
      "lxc.cgroup.devices.allow: a",
      "lxc.cap.drop:",
    ],
    # Docker inside lxc requires those modules enabled on the host
    host_kernel_modules: [
      "aufs",
      "overlay",
    ]
  }

  source    = "../../modules/terraform/proxmox/lxc_bitwarden"

  dependencies = [
    module.lxc_consul.provisioner_id
  ]

  tags = {
    http = [
      "traefik.enable=true",
      "traefik.http.routers.bitwarden_rs.entryPoints=https",
      "traefik.http.routers.bitwarden_rs.rule=Host(`${var.lxc.bitwarden.hostname}`)",
      "traefik.http.routers.bitwarden_rs.tls.certResolver=<dns_challenge_cert_resolver>",
      "traefik.http.routers.bitwarden_rs.service=bitwarden_rs@consulcatalog",
    ]

    wss = [
      "traefik.enable=true",
      "traefik.http.routers.bitwarden_rs_wss.entryPoints=https",
      "traefik.http.routers.bitwarden_rs_wss.rule=Host(`${var.lxc.bitwarden.hostname}`) && Path(`/notifications/hub`)",
      "traefik.http.routers.bitwarden_rs_wss.tls.certResolver=<dns_challenge_cert_resolver>",
      "traefik.http.routers.bitwarden_rs_wss.service=bitwarden_rs-wss@consulcatalog",
    ]
  }
}
```

## References ##

- [https://github.com/dani-garcia/bitwarden_rs](https://github.com/dani-garcia/bitwarden_rs)
