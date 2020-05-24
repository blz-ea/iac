# PVE #

Kernel Version: 5.4.27-1-pve
PVE Manager Version: 6.1-8

Terraform workspace defines what variables will be loaded from `vars` folder

## Build Templates ##

```bash
packer build ./templates/<template>/
```

## Structure ##

```
modules
  ansible-roles
  bash
  terraform
pve
  dns
  file
  lxc
  pool
  templates
  time
  vm
  ansible.cfg
  providers.tf
  pve.tf
  pve.yml - ansible playbook to Proxmox node
vars
requirements.yml
```

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
