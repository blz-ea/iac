locals {
  vpc_id = module.vpc.vpc_id
  ec2_user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install nginx -y
sudo service nginx start
EOF
  tags = {
    Terraform   = "true"
    Environment = "Lab"
  }
}

data "aws_region" "default" {}
data "aws_caller_identity" "default" {}

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

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 2
}

#############################################################
# SSH Keys
#############################################################
resource "aws_key_pair" "default_ssh_key" {
  key_name      = var.default_ssh_key_name
  public_key    = file(pathexpand(var.default_ssh_key_location))
}
