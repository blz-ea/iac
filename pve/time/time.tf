#
# Sets Time Settings in Proxmox Virtual Environment
#
resource "proxmox_virtual_environment_time" "pve" {
    node_name = var.proxmox.nodes.pve.name
    time_zone = var.proxmox.nodes.pve.time_zone
    # local_time = ""
    # utc_time = ""
}