# Traefik Ansible Role #

Ansible role for setting up [Traefik](https://github.com/containous/traefik/) reverse proxy as a systemd service

## Usage ##

```ansible
- name: Install Traefik Service
  include_role:
    name: traefik
    apply:
      tags:
        - always
  vars:
    systemd_user: root
    systemd_group: root
    traefik_environment: [
      "CLOUDFLARE_API_KEY=<cloudflare_api_key>",
      "CLOUDFLARE_EMAIL=<cloudflare_email>",
    ]
    traefik_cli_options: [
      # Static configuration
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
```

## References ##

- [https://docs.traefik.io/](https://docs.traefik.io/)
