<h1 align=center>Infrastructure  as Code Starter Kit</h1>

<div align="center">
<img src="./.github/header.png">
</div>

A boilerplate to create a full Infrastructure as Code repository for various cloud environments, from provisioning to deployment with:

- **Terraform**
- **Ansible**
- **Packer**

## Requirements ##

- **nix OS or WSL**
- **Terraform > 0.12.24**
- **Ansible > 2.9.6**
- **Packer > 1.6.0**

## Folder Structure ##

- `modules` - Contains modular components
  - `ansible-roles` - Ansible roles
  - `bash` - Bash scripts
  - `terraform` - Terraform modules
- `pve` - Proxmox Virtual Environment
- `aws` - Amazon Web Services environment [WIP]
- `k8s` - Kubernetes environment [WIP]
- `vars` - Workspace variables
  - `default.yml` - Default variables that will be loaded alongside with others
  - `<your_env_here>.yml` - Environment variables for specific environment
- `requirements.yml` - Local requirements Ansible playbook

**Note**: Terraform's workspace value defines what variables will be loaded from `vars` folder

## Quick start ##

### Step 1: Clone repository ###

```bash
git clone git@github.com:blz-ea/devops.git
```

### Step 2: Install requirements ###

```bash
make start
```

or manually install

- Ansible
- Terraform
- Packer

### Step 3: Select environnement ###

- [Proxmox Virtual Environment](./pve/)
- Amazon Web Services
  - [Basic example](./aws/basic/)
  - ...
- K8S [WIP]

## Notes ##

### On using in WSL ###

If Ansible throws an error related to  `ansible.cfg` permissions. Add below to `/etc/wsl.conf` and restart WSL

```conf
[Automount]
enabled = true
mountFsTab = false
root = /mnt/
options = "metadata,umask=22,fmask=11"

[network]
generateHosts = true
generateResolvConf = true

```

### Terraform's Consul Plugin Deprecation warning ###

Due to issues with `consul_service` resource, resource  `consul_agent_service` with deprecation warning is used

#### References ####

- https://github.com/terraform-providers/terraform-provider-consul/issues/124
- https://github.com/terraform-providers/terraform-provider-consul/issues/187
- https://github.com/hashicorp/consul/issues/7513

## TODO ##

- Add tests
- Decouple variable into smaller files, add support for Hashicorp Vault
