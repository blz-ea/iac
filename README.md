# Collection of automation tools #

## Requirements ##

- nix OS or WSL
- Terraform > 0.12.24
- Golang > 1.14
- Ansible > 2.9.6

## WSL ##

**Note on using in WSL**

If Ansible throws error related to `ansible.cfg`. Add below to `/etc/wsl.conf`

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