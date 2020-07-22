terraform {
  required_version = ">= 0.12"
}

locals {
	vpc_id = module.vpc.vpc_id
	tags = {
		Terraform   = "true"
		Environment = "Lab"
	}
	ec2_user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install nginx -y
sudo service nginx start
EOF

}

provider "aws" {
  region      = var.aws_region
  access_key  = var.aws_access_key
  secret_key  = var.aws_secret_key
}

data "aws_region" "default" {}
data "aws_caller_identity" "default" {}

#############################################################
# Virtual Private Cloud (VPC)
#############################################################
module "vpc" {
	source = "terraform-aws-modules/vpc/aws"
	version = "2.39.0"

	name 			= var.vpc_name
	cidr 			= var.vpc_cidr_block
	azs 			= var.vpc_azs
	private_subnets = var.vpc_private_subnet
	public_subnets 	= var.vpc_public_subnet

	enable_nat_gateway = true
	single_nat_gateway = true

	tags = local.tags
}

#############################################################
# Security Groups
#############################################################
# Load Balancer Security Group
module "alb_sg" {
	source = "terraform-aws-modules/security-group/aws"

	name 				= "alb-sg"
	description 		= "ALB Security group"
	vpc_id 				= local.vpc_id

	ingress_cidr_blocks = ["0.0.0.0/0"]
	ingress_rules = [
		"http-80-tcp",
		"https-443-tcp",
		"all-icmp",
	]
	egress_rules = ["all-all"]
	
}

# Allow HTTP traffic security group
module "web_instance_http_sg" {
	source = "terraform-aws-modules/security-group/aws"

	name 			= "web_instance_http_sg"
	description 	= "HTTP Security group"
	vpc_id 			= local.vpc_id

	ingress_cidr_blocks = ["0.0.0.0/0"]
	ingress_rules 		= ["http-80-tcp", "all-icmp"]
	egress_rules 		= ["all-all"]

	computed_ingress_with_source_security_group_id = [
		{
			rule = "alb-http"
			source_security_group_id = module.alb_sg.this_security_group_id
		}
	]
}

# Allow SSH traffic security group
module "ssh_sg" {
	source = "terraform-aws-modules/security-group/aws"

	name 		= "ssh-sg"
	description	= "SSH Security group"
	vpc_id 		= local.vpc_id

	ingress_cidr_blocks = ["0.0.0.0/0"]
	ingress_rules 		= ["ssh-tcp"]
	egress_rules 		= ["all-all"]
	
}

#############################################################
# Application LoadBalancer (ALB)
#############################################################
module "alb" {
	source 	= "terraform-aws-modules/alb/aws"
	version = "5.6.0"
	name 	= "default-elb"

	load_balancer_type = "application"
	vpc_id 	= local.vpc_id
	subnets = module.vpc.public_subnets
	
	security_groups = [
		module.alb_sg.this_security_group_id
	]

	# access_logs = {
	#		enabled = true
	# 	bucket = "default-alb-logs"
	# 	prefix = "default-alb"
	# }

	https_listeners = [
		{
			target_group_index 	= 0
			port 				= 443
			protocol 			= "HTTPS"
			certificate_arn 	= module.acm.this_acm_certificate_arn
		}
	]

	http_tcp_listeners = [
		{
			port		= 80
			protocol 	= "HTTP"
			action_type = "redirect"
			redirect = {
				port 		= 443
				protocol 	= "HTTPS"
				status_code = "HTTP_301"
			}
		}
	]

	target_groups = [
		{
			name_prefix 		= "web"
			backend_protocol 	= "HTTP"
			backend_port 		= 80
			target_type 		= "instance"
			deregistration_delay=	10

			health_check = {
				enabled 			= true
				interval 			= 30
				path 				= "/"
				port				= "traffic-port"
				healthy_threshold	= 3
				unhealthy_threshold = 3
				timeout 			= 6
				protocol 			= "HTTP"
				matcher 			= "200-399"
			}
		}
	]

	tags = local.tags
	lb_tags = local.tags
	target_group_tags = local.tags
}

#############################################################
# Auto Scaling Group (ASG)
#############################################################
# WEB instance
module "asg" {
	source 				= "terraform-aws-modules/autoscaling/aws"
	version 			= "3.5.0"
	name 				= "web_service"
	
	# Launch configuration
	lc_name 			= "web-lc"
	image_id 			= data.aws_ami.amazon_linux.id
	instance_type 		= var.ec2_instance_type
	user_data 			= local.ec2_user_data
	recreate_asg_when_lc_changes = false
	# ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "50"
  #     delete_on_termination = true
  #   },
  # ]

  # root_block_device = [
  #   {
  #     volume_size = "50"
  #     volume_type = "gp2"
  #   },
  # ]

	security_groups = [
		module.web_instance_http_sg.this_security_group_id,
		module.ssh_sg.this_security_group_id,
	]

	# Auto scaling group
	asg_name 			= "web-asg"
	vpc_zone_identifier = module.vpc.private_subnets
	health_check_type 	= "EC2"
	min_size 			= 0
	max_size 			= 4
	desired_capacity 	= 4
	wait_for_capacity_timeout = 0

	target_group_arns = [
		module.alb.target_group_arns[0]
	]

	tags_as_map = local.tags
}

#############################################################
# ACM
#############################################################
module "acm" {
	source 				= "terraform-aws-modules/acm/aws"
	version 			= "2.8.0"
	zone_id 			= data.aws_route53_zone.primary.id
	domain_name 		= trimsuffix(data.aws_route53_zone.primary.name, ".")
	subject_alternative_names = var.route53_primary_zone_alternative_names
}

#############################################################
# SSH Keys
#############################################################
resource "aws_key_pair" "default_ssh_key" {
	key_name 		= var.default_ssh_key_name
	public_key 		= file(pathexpand(var.default_ssh_key_location))
}

#############################################################
# Route 53
#############################################################
data "aws_route53_zone" "primary" {
	name = var.route53_primary_zone_name
}

resource "aws_route53_record" "www" {
	zone_id = data.aws_route53_zone.primary.zone_id
	name 		= var.route53_primary_zone_name
	type 		= "A"

	alias {
		name 	= module.alb.this_lb_dns_name
		zone_id = module.alb.this_lb_zone_id
		evaluate_target_health = false
	}

}

#############################################################
# AMI
#############################################################
data "aws_ami" "amazon_linux" {
	most_recent = true
	owners = ["amazon"]

	filter {
		name = "name"
		values = [
		  "amzn-ami-hvm-*-x86_64-gp2",
		]
	}

	filter {
		name = "owner-alias"
		values = [
			"amazon",
		]
	}
}
