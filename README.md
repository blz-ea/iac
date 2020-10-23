<h1 align=center>Infrastructure  as Code Starter Kit</h1>

<div align="center">
<img src="./.github/header.png">
</div>

A boilerplate to create a full Infrastructure as Code for various cloud environments, from provisioning to deployment

## Requirements ##

| Name          | Version |
|---------------|---------|
| nix OS or WSL |  |
| terraform     | \>= 0.13 |
| packer        | = 1.6.0 |
| ansible       | \>= 2.9.6 |

## Folder Structure ##

- `modules` - Contains modular components
  - `ansible-roles` - Ansible roles
  - `bash` - Bash scripts
  - `terraform` - Terraform modules
  - `helm` - Helm charts
- `pve` - Proxmox Virtual Environment
- `aws` - Amazon Web Services environment
- `requirements.yml` - Local requirements (Ansible playbook)

## Quick start ##

### Step 1: Clone repository ###

```bash
git clone git@github.com:blz-ea/devops.git
```

### Step 2: Install requirements ###

```bash
make install
```

or manually install

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Packer](https://learn.hashicorp.com/packer/getting-started/install)

### Environments ###

- [Proxmox Virtual Environment](./pve/)
- Amazon Web Services
  - [Basic example](./aws/basic/)
  - ...

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
## TODO ##

- Add tests
- Add support for Hashicorp Vault
- Refactor