#############################################################
# Route 53
#############################################################
data "aws_route53_zone" "primary" {
  name = var.route53_primary_zone_name
}

resource "aws_route53_record" "www" {
  zone_id   = data.aws_route53_zone.primary.zone_id
  name      = var.route53_primary_zone_name
  type      = "A"

  alias {
    name     = module.alb.this_lb_dns_name
    zone_id  = module.alb.this_lb_zone_id
    evaluate_target_health = false
  }

}

#############################################################
# ACM
#############################################################
module "acm" {
  source          = "terraform-aws-modules/acm/aws"
  zone_id         = data.aws_route53_zone.primary.id
  domain_name     = trimsuffix(data.aws_route53_zone.primary.name, ".")
  subject_alternative_names = var.route53_primary_zone_alternative_names
}