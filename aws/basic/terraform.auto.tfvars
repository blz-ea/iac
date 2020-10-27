#############################################################
# AWS Credentials
#############################################################
# AWS access key
aws_access_key = ""

# AWS secret key
aws_secret_key = ""

# Route 53 zone name (e.g. example.com)
route53_primary_zone_name = ""

# List of alternative names (e.g. *.example.com)
route53_primary_zone_alternative_names = []
#############################################################
# User variables
#############################################################
default_admin_email = "admin@example.com"
default_admin_username = "deploy"
#############################################################
# SSH variables
#############################################################
# SSH key name
default_ssh_key_name = "default"

# SSH key location
default_ssh_key_location = "~/.ssh/id_rsa.pub"

#############################################################
# VPC Variables
#############################################################
# Virtual Private Cloud (VPC) name
vpc_name = "default"

# VPC CIDR block
vpc_cidr_block = "10.10.0.0/16"

# Availability zones where VPC will be places
vpc_azs = [
  "us-east-1a",
  "us-east-1b",
]

# VPC public subnets
vpc_public_subnet = [
  "10.10.1.0/24",
  "10.10.2.0/24",
]

# VPC private subnets
vpc_private_subnet = [
  "10.10.11.0/24",
  "10.10.12.0/24",
]

#############################################################
# EC2 Variables
#############################################################
# EC2 Instance type
ec2_instance_type = "t2.micro"

#############################################################
# S3
#############################################################
# S3 Data Bucket name
s3_data_bucket_name = "data-bucket-tf-demo"