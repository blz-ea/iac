# [Proxmox](https://www.proxmox.com/) Virtual Environment #

<div align="center">
<img src="../.github/header_pve.png">
</div>

```pseudo
Kernel Version: 5.4.27-1-pve
PVE Manager Version: 6.2-6
```

## Requirements ##

- **[Terraform Proxmox Plugin](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/installation.md)**
- **Golang > 1.14**
- **Access to Proxmox API**
- **Access to Proxmox via SSH**

## Folder Structure ##

- `pve` - Proxmox Virtual Environment
  - `templates` - Packer templates
  - `bastion` - Digital Ocean Bastion Host
  - `discovery` - Internal web services exposed via proxy
  - `dns` - Dns records
  - `file` - File resources (e.g. iso, lxc images)
  - `lxc` - LXC Containers
  - `pool`- Grouped resources into pools
  - `time` - Time related configuration
  - `vm` - Virtual Machines
  - `ansible.cfg` - Ansible configuration file
  - `providers.tf` - All providers used in current environment
  - `pve.tf` - Main entry point
  - `pve.yml`  - Additional configuration applied to Proxmox node
  - `requirements.yml` Local requirements

## `pve.yml` - additional configuration applied to Proxmox node ##

- Removes Proxmox Enterprise repository from sources (`--tags subscription`)
- Adds Debian Sources repository (`--tags sources`)
- Upgrade packages (`--tags upgrade`)
- Install Intel Graphics driver (`--tags intel-graphics`)
- Removes Subscription Popup (`--tags popup`)
- Enables PCI passthrough (`--tags vfio`, reboot required)
  - Adds bootloader options
  - Adds kernel modules
  - Blacklist Nvidia and Radeon Drivers
  - Adds PCI devices to vfio-pci drivers (must be listed in variables)
- Reboot (`--tags reboot`)

## Quick start ##

### Step 1: Install requirements ###

```bash
make start
```

or manually install

- Golang
- [Terraform Proxmox Plugin](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/installation.md)

### Step 2: Setup variables ###

- Create Terraform workspace `terraform workspace new <environment>`
- Create environmental variable file in `../vars` similar to [../vars/default_proxmox.yml](../vars/default_proxmox.yml)
- Change workspace: `terraform workspace select <environnement>`

### Step 3: Start Deployment ###

```bash
make init
make plan
make apply
```

## Current Setup ##

- LXC Containers
  - [Bind9 DNS Server](../modules/terraform/proxmox/lxc_bind)
    - DNS-over-HTTPS client
    - DNS-over-HTTPS server
  - [Consul Server](../modules/terraform/proxmox/lxc_consul)
  - [LocalStack](../modules/terraform/proxmox/lxc_localstack)
  - [Traefik](../modules/terraform/proxmox/lxc_traefik)
  - [PiHole](../modules/terraform/proxmox/lxc_pihole)
  - [Plex](../modules/terraform/proxmox/lxc_plex)
  - [Jellyfin](../modules/terraform/proxmox/lxc_jellyfin)
  - [Bitwarden](../modules/terraform/proxmox/lxc_bitwarden)
  - [Home Assistant](../modules/terraform/proxmox/lxc_home_assistant)
- VMS
  - ...
- Bastion Host
  - Docker
    - [Traefik](../modules/terraform/docker/traefik)
    - [Drone CI Server](../modules/terraform/docker/drone)
    - [Docker Registry](../modules/terraform/docker/registry)
- Cloudflare DNS Records

## TODO ##

- Add a network map
