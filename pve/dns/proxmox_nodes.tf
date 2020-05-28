# 
# Proxmox Nodes DNS settings
# 
resource "proxmox_virtual_environment_dns" "pve_node_dns_configuration" {
  domain = var.domain.name
  node_name = var.proxmox.nodes.pve.name
  servers = var.domain.dns_servers
}
