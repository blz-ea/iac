locals {
  cloudflare_main_domain_zone_id = lookup(data.cloudflare_zones.main_domain.zones[0], "id")
}

data "cloudflare_zones" "main_domain" {
  filter {
    name   = var.domain_name
    status = "active"
    paused = false
  }
}

#############################################################
# Cloudflare - Bastion Host Records
#############################################################
resource "cloudflare_record" "root" {
  zone_id   = local.cloudflare_main_domain_zone_id
  name      = ""
  value     = digitalocean_droplet.bastion.ipv4_address
  type      = "A"
  proxied   = false
}

resource "cloudflare_record" "any" {
  zone_id   = local.cloudflare_main_domain_zone_id
  name      = "*"
  value     = digitalocean_droplet.bastion.ipv4_address
  type      = "A"
  proxied   = false
}

resource "cloudflare_record" "www" {
  zone_id   = local.cloudflare_main_domain_zone_id
  name      = "www"
  value     = digitalocean_droplet.bastion.ipv4_address
  type      = "A"
  proxied   = false
}

#############################################################
# Cloudflare - MX Records
#############################################################
resource "cloudflare_record" "mx1" {
  zone_id = local.cloudflare_main_domain_zone_id
  name    = var.domain_name
  value   = "alt4.gmr-smtp-in.l.google.com"
  type    = "MX"
  priority = 40
}

resource "cloudflare_record" "mx2" {
  zone_id = local.cloudflare_main_domain_zone_id
  name    = var.domain_name
  value   = "alt3.gmr-smtp-in.l.google.com"
  type    = "MX"
  priority = 30
}

resource "cloudflare_record" "mx3" {
  zone_id = local.cloudflare_main_domain_zone_id
  name    = var.domain_name
  value   = "alt2.gmr-smtp-in.l.google.com"
  type    = "MX"
  priority = 20
}

resource "cloudflare_record" "mx4" {
  zone_id = local.cloudflare_main_domain_zone_id
  name    = var.domain_name
  value   = "alt1.gmr-smtp-in.l.google.com"
  type    = "MX"
  priority = 10
}

resource "cloudflare_record" "mx5" {
  zone_id = local.cloudflare_main_domain_zone_id
  name    = var.domain_name
  value   = "gmr-smtp-in.l.google.com"
  type    = "MX"
  priority = 5
}

#############################################################
# Local DNS Records
#############################################################
# # DNS Record Template
# resource "dns_a_record_set" "" {
#   zone      = "${var.domain_name}."
#   name      = ""
#   addresses = [
#     var.hostname
#   ]
#   ttl       = 300
# }

# data "dns_a_record_set" "" {
#   # Last bit is a hacky dependency
#   host    = "${}${replace(join("", dns_a_record_set. .addresses) , "/.*/", "")}"
# }

# output "consul_a_record" {
#   value = data.dns_a_record_set
# }