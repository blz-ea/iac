# Collection of automation tools #

## Requirements ##

- nix OS or WSL
- Terraform > 0.12.24
- Golang > 1.14
- Ansible > 2.9.6
- Access to Proxmox API
- Access to Proxmox via SSH

### Plugins ##

- [Terraform Proxmox Plugin](https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/installation.md)

## WSL ##

**Note on using in WSL**
If Ansible throws an error related to  `ansible.cfg` permissions. Add below to `/etc/wsl.conf`

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

## Re-provision ##

```bash
terraform taint -state terraform.tfstate.d/<workspace>/terraform.tfstate module.<name>c.module.<container_name>.null_resource.provision
terraform apply
```

## Terraform's Consul Plugin Deprecation warning ##

Due to issues with `consul_service` resource, `consul_agent_service` resource is used

References:
 - https://github.com/terraform-providers/terraform-provider-consul/issues/124
 - https://github.com/terraform-providers/terraform-provider-consul/issues/187
 - https://github.com/hashicorp/consul/issues/7513

## Module Dependencies ##

Workaround is used to infer module dependencies

```terraform
resource "null_resource" "dependencies" {
  triggers {
    depends_on = "${join("", var.dependencies)}"
  }
}
```
