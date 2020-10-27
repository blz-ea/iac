data "aws_iam_policy" "administrators_access" {
  # Ref: https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/AdministratorAccess
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "power_user_access" {
  # Ref: https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/PowerUserAccess
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy" "billing" {
  # Ref: https://console.aws.amazon.com/iam/home#/policies/arn:aws:iam::aws:policy/job-function/Billing
  arn = "arn:aws:iam::aws:policy/job-function/Billing"
}

#############################################################
# IAM - Groups
#############################################################
# Admins Group
resource "aws_iam_group" "administrators" {
  name = "administrators"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "administrators_attach" {
  group       = aws_iam_group.administrators.name
  policy_arn  = data.aws_iam_policy.administrators_access.arn
}

#############################################################
# IAM - Policy
#############################################################
resource "aws_iam_policy" "ec2_describe" {
  name        = "ec2-describe"
  description = "Allows list EC2 instances"
  policy      = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: [
          "ec2:Describe*"
        ],
        Effect: "Allow",
        Resource: "*"
      }
    ]
  })
}

