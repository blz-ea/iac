#############################################################
# AWS Credentials
#############################################################
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

#############################################################
# Route53 variables
#############################################################
variable "route53_primary_zone_name" {
  description = "Route 53 zone name (e.g. example.com)"
  type = string
}

variable "route53_primary_zone_alternative_names" {
  description = "List of alternative names (e.g. *.example.com)"
  type = list(string)
  default = []
}

#############################################################
# User variables
#############################################################
variable "default_admin_username" {
  description = "Admin username"
  type = string
  default = "deploy"
}

variable "default_admin_email" {
  description = "Admin email"
  type = string
}
#############################################################
# SSH variables
#############################################################
variable "default_ssh_key_name" {
  description = "SSH key name"
  type = string
  default = "default"
}

variable "default_ssh_key_location" {
  description = "SSH key location"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

#############################################################
# VPC Variables
#############################################################
variable "vpc_name" {
  description = "Virtual Private Cloud (VPC) name"
  type = string
  default = "default"
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block"
  type = string
  default = "10.10.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones where VPC will be places"
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
  ]
}

variable "vpc_public_subnet" {
  description = "VPC public subnets"
  type = list(string)
  default = [
    "10.10.1.0/24",
    "10.10.2.0/24",
  ]
}

variable "vpc_private_subnet" {
  description = "VPC private subnets"
  type = list(string)
  default = [
    "10.10.11.0/24",
    "10.10.12.0/24",
  ]
}

#############################################################
# EC2 Variables
#############################################################
variable "ec2_instance_type" {
  description = "EC2 Instance type"
  type = string
  default = "t2.micro"
}

#############################################################
# S3
#############################################################
variable "s3_data_bucket_name" {
  description = "S3 Data Bucket name"
  type = string
}