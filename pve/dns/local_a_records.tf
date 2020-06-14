# # DNS Record
# resource "dns_a_record_set" "consul_a_record" {
#   zone      = "${var.domain.name}."
#   name      = "consul"
#   addresses = [
#     var.consul.default.host
#   ]
#   ttl       = 300
# }

# data "dns_a_record_set" "consul_a_record" {
#   # Last bit is a hacky dependency
#   host    = "${var.lxc.consul.hostname}${replace(join("", dns_a_record_set.consul_a_record.addresses) , "/.*/", "")}"
# }

# output "consul_a_record" {
#   value = data.dns_a_record_set.consul_a_record
# }