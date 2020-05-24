#
# Create Resource Pool in Proxmox Virtual Environemnt
#
resource "proxmox_virtual_environment_pool" "pve" {
  comment = "Managed by Terraform"
  pool_id = "pve"  
}

output "pools" {
    value = {
        pve = proxmox_virtual_environment_pool.pve
    }
}