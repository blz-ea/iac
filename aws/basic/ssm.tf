data "aws_iam_policy" "AmazonSSMReadOnlyAccess" {
  # Ref: https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess$jsonEditor
  arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  # Ref: https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore$jsonEditor
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

#############################################################
# VPC Endpoints
# Required for EC2 instances that do not have internet access
# Ref:
# - https://aws.amazon.com/premiumsupport/knowledge-center/ec2-systems-manager-vpc-endpoints/
#############################################################
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc_endpoints_sg.this_security_group_id
  ]

  private_dns_enabled = true
  subnet_ids = [
    module.vpc.private_subnets.0
  ]

  tags = merge(local.tags, {})
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc_endpoints_sg.this_security_group_id
  ]

  private_dns_enabled = true
  subnet_ids = [
    module.vpc.private_subnets.0
  ]

  tags = merge(local.tags, {})
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    module.vpc_endpoints_sg.this_security_group_id
  ]

  private_dns_enabled = true
  subnet_ids = [
    module.vpc.private_subnets.0
  ]

  tags = merge(local.tags, {})
}

#############################################################
# Security Groups
#############################################################
# VPC Endpoint security group
module "vpc_endpoints_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name 				= "vpc-endpoint-sg"
  description 		= "VPC Endpoint security group"
  vpc_id 			= local.vpc_id

  ingress_cidr_blocks = [var.vpc_cidr_block]
  ingress_rules = [
    "https-443-tcp",
  ]
  egress_rules = ["all-all"]
}

#############################################################
# IAM
#############################################################
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role = aws_iam_role.SSMInstanceProfile.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "SSMInstanceProfileS3Policy" {
  role = aws_iam_role.SSMInstanceProfile.name
  policy_arn = aws_iam_policy.SSMInstanceProfileS3Policy.arn
}

#############################################################
# IAM - Groups
#############################################################
# Ref:
# - [Restricting Run Command access based on instance tags](https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-rc-setting-up.html)
resource "aws_iam_policy" "SSMPolicyFinanceWebServers" {
  name        = "SSMPolicyFinanceWebServers"
  description = "Allows access to instances that are tagged as `Finance: WebServers`"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
       Effect: "Allow",
       Action:[
         "ssm:SendCommand",
         "ssm:StartSession",
       ],
        Resource:[
          "arn:aws:ssm:*:*:document/*"
        ],
      },
      {
        Effect: "Allow",
        Action: [
          "ssm:SendCommand",
          "ssm:StartSession",
        ],
        Resource: [
            "arn:aws:ec2:*:*:instance/*"
        ],
        Condition: {
          "StringLike": {
            "ssm:resourceTag/Finance": [
                "WebServers"
            ]
          }
        }
      },
      {
        Effect: "Allow",
        Action: [
          "ssm:ResumeSession",
          "ssm:TerminateSession",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus"
        ],
        Resource: [
          "arn:aws:ssm:*:*:session/$${aws:username}-*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "SSMInstanceProfileS3Policy" {
  name        = "SSMInstanceProfileS3Policy"
  description = ""
  policy      = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Action: "s3:GetObject",
            Resource: [
                "arn:aws:s3:::aws-ssm-${var.aws_region}/*",
                "arn:aws:s3:::aws-windows-downloads-${var.aws_region}/*",
                "arn:aws:s3:::amazon-ssm-${var.aws_region}/*",
                "arn:aws:s3:::amazon-ssm-packages-${var.aws_region}/*",
                "arn:aws:s3:::${var.aws_region}-birdwatcher-prod/*",
                "arn:aws:s3:::aws-ssm-distributor-file-${var.aws_region}/*",
                "arn:aws:s3:::aws-ssm-document-attachments-${var.aws_region}/*",
                "arn:aws:s3:::patch-baseline-snapshot-${var.aws_region}/*"
            ]
        },
        {
            Effect: "Allow",
            Action: [
                "s3:GetObject",
                "s3:PutObject",
//                "s3:PutObjectAcl", # for cross account access
//                "s3:GetEncryptionConfiguration" # for encrypted buckets only
            ],
            Resource: [
                "arn:aws:s3:::sys-manager-001/*",
//                "arn:aws:s3:::sys-manager-001" # for encrypted buckets only
            ]
        }
    ]
  })
}

# SSM Read Only Group
resource "aws_iam_group" "ssm_read_only" {
  name = "ssm_read_only"
  path = "/"
  // TODO: Add
  // AWSHealthFullAccess
  // AWSConfigUserAccess
  // CloudWatchReadOnlyAccess
}

resource "aws_iam_group_policy_attachment" "amazon_ssm_read_only_access" {
  group = aws_iam_group.ssm_read_only.name
  policy_arn = data.aws_iam_policy.AmazonSSMReadOnlyAccess.arn
}

#############################################################
# SSM Document
# Ref:
# - https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-configure-preferences-cli.html
# - https://www.terraform.io/docs/providers/aws/r/ssm_document.html
#############################################################
//resource "aws_ssm_document" "default" {
//  name            = var.ssm_document_name
//  document_type   = "Session"
//  document_format = "JSON"
//  tags            = merge({ "Name" = var.ssm_document_name }, var.tags)
//
//  content = jsonencode({
//    schemaVersion = "1.0"
//    description   = "Document to hold regional settings for Session Manager"
//    sessionType   = "Standard_Stream"
//    inputs = {
//      s3BucketName                = var.s3_bucket_name
//      s3KeyPrefix                 = var.s3_key_prefix
//      s3EncryptionEnabled         = var.s3_encryption_enabled
//      cloudWatchLogGroupName      = var.cloudwatch_log_group_name
//      cloudWatchEncryptionEnabled = var.cloudwatch_encryption_enabled
//    }
//  })
//}
