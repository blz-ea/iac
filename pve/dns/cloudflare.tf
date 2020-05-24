#
# MX Records
#
resource "cloudflare_record" "mx1" {
  zone_id = var.cloudflare.zone_id
  name = var.domain.name
  value = "alt4.gmr-smtp-in.l.google.com"
  type = "MX"
  priority = 40 
}

resource "cloudflare_record" "mx2" {
  zone_id = var.cloudflare.zone_id
  name = var.domain.name
  value = "alt3.gmr-smtp-in.l.google.com"
  type = "MX"
  priority = 30 
}

resource "cloudflare_record" "mx3" {
  zone_id = var.cloudflare.zone_id
  name = var.domain.name
  value = "alt2.gmr-smtp-in.l.google.com"
  type = "MX"
  priority = 20 
}

resource "cloudflare_record" "mx4" {
  zone_id = var.cloudflare.zone_id
  name = var.domain.name
  value = "alt1.gmr-smtp-in.l.google.com"
  type = "MX"
  priority = 10 
}

resource "cloudflare_record" "mx5" {
  zone_id = var.cloudflare.zone_id
  name = var.domain.name
  value = "gmr-smtp-in.l.google.com"
  type = "MX"
  priority = 5 
}
