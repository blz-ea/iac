#############################################################
# VPC
# Ref: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/
#############################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name        = var.vpc_name
  cidr        = var.vpc_cidr_block
  azs         = var.vpc_azs
  private_subnets    = var.vpc_private_subnet
  public_subnets     = var.vpc_public_subnet
  enable_s3_endpoint = true
  single_nat_gateway = true
  enable_nat_gateway    = true
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = local.tags
}