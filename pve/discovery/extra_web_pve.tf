
locals {
	# Expecting var.proxmox.nodes.pve.api.url to be in <scheme>:<host>:<port> format
	proxmox_pve_web_ui_host 		= split(":", split("//", var.proxmox.nodes.pve.api.url)[1])[0]
	proxmox_pve_web_ui_port 		= split(":", var.proxmox.nodes.pve.api.url)[2] # Get the port e.g. 8006
	proxmox_pve_web_ui_scheme 	= split(":", var.proxmox.nodes.pve.api.url)[0] # Get the scheme e.g. https
	proxmox_pve_hostname 				= var.proxmox.nodes.pve.hostname
}

# Expose Proxmox Web UI to traefik
resource "consul_agent_service" "proxmox_node_pve" {
	address = local.proxmox_pve_web_ui_host
  port = local.proxmox_pve_web_ui_port
  name = "proxmox_node_pve"
  tags = [
	  "traefik.enable=true",
		"traefik.http.routers.proxmox_node_pve.entryPoints=https",
	  "traefik.http.routers.proxmox_node_pve.rule=Host(`${local.proxmox_pve_hostname}`)",
		"traefik.http.routers.proxmox_node_pve.tls.certResolver=cloudflare",
		"traefik.http.services.proxmox-node-pve.loadbalancer.server.scheme=${local.proxmox_pve_web_ui_scheme}",
	  "traefik.http.routers.proxmox_node_pve.service=proxmox-node-pve@consulcatalog",
  ]

	depends_on = [ null_resource.depends_on ]
}