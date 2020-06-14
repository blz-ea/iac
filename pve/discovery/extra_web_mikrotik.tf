
resource "consul_agent_service" "mikrotik" {
	address = "192.168.88.1"
  port = 80
	name = "mikrotik"
  tags = [
	  "traefik.enable=true",
		"traefik.http.routers.mikrotik.entryPoints=https",
	  "traefik.http.routers.mikrotik.rule=Host(`mikrotik.devset.app`)",
		"traefik.http.routers.mikrotik.tls.certResolver=cloudflare",
	  "traefik.http.routers.mikrotik.service=mikrotik@consulcatalog",
  ]

	depends_on = [ null_resource.depends_on ]
}