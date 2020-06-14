# LXC Register #

Registers Proxmox LXC container's IP addresses in Consul KV Store
Used by Terraform provisioners

Usage

```terraform
provisioner "local-exec" {
  command = "ansible-playbook -i <proxmox_node_name>, ../modules/ansible-roles/lxc_register/tasks/main.yml -e 'ansible_user=<proxmox_username>'"
  environment = {
    ANSIBLE_CONFIG = "../ansible.cfg",
    ANSIBLE_FORCE_COLOR = "True",
    TERRAFORM_CONFIG = yamlencode({
      pve_node = <proxmox_node_name>
      consul = {
          host = <consul_host>
          port = <consul_port>
          scheme = <consul_scheme>
      }
      container_id  = <lxc_container_id>
    }),
  }
}
```
