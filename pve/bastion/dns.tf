resource "cloudflare_record" "root" {
  zone_id   = var.cloudflare.zone_id
  name      = ""
  value     = digitalocean_droplet.bastion.ipv4_address
  type      = "A"
  proxied   = true
}

resource "cloudflare_record" "any" {
  zone_id   = var.cloudflare.zone_id
  name      = "*"
  value     = digitalocean_droplet.bastion.ipv4_address
  type      = "A"
  proxied   = false
}

resource "cloudflare_record" "www" {
  zone_id   = var.cloudflare.zone_id
  name      = "www"
  value     = digitalocean_droplet.bastion.ipv4_address
  type      = "A"
  proxied   = true
}