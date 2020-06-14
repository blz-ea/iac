# Localstack module #

Terraform module for setting up [Localstack](https://github.com/localstack/localstack) a fully functional local AWS cloud stack inside LXC container in Proxmox Virtual Environment

## Usage ##

```terraform
module "lxc_localstack" {

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
    container_name: "aws",
    hostname: "aws.example.com",
    hostname_endpoint: "edge.aws.example.com",
    cert_resolver: <dns_challenge_cert_resolver>,
    memory: {
      dedicated: 2048,
      swap: 1024,
    },
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
  },

  source    = "../../modules/terraform/proxmox/lxc_localstack"

  dependencies = [
    module.lxc_consul.provisioner_id
  ]

  # Consul agent tags
  # Expose localstack webui and edge service via Traefik
  tags = {

    webui = [
      "traefik.enable=true",
      "traefik.http.routers.localstack.entryPoints=https",
      "traefik.http.routers.localstack.rule=Host(`aws.example.com`)",
      "traefik.http.routers.localstack.tls.certResolver=<dns_challenge_cert_resolver>",
      "traefik.http.routers.localstack.service=localstack@consulcatalog",
    ]

    edge = [
      "traefik.enable=true",
      "traefik.http.routers.localstack_edge.entryPoints=https",
      "traefik.http.routers.localstack_edge.rule=Host(`edge.aws.example.com`)",
      "traefik.http.routers.localstack_edge.tls.certResolver=<dns_challenge_cert_resolver>",
      "traefik.http.routers.localstack_edge.service=localstack-edge@consulcatalog",
    ]
  }
}
```

## References ##

- [https://github.com/localstack/localstack](https://github.com/localstack/localstack)
