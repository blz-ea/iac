#############################################################
# IAM Users - deploy
#############################################################
resource "aws_iam_user_ssh_key" "user_deploy" {
  username   = var.default_admin_email
  encoding   = "SSH"
  public_key = file(pathexpand(var.default_ssh_key_location))
}

resource "aws_iam_access_key" "user_deploy" {
  user    = var.default_admin_email
  status  = "Active" # or Inactive
//  pgp_key = "keybase:some_person_that_exists"
}

resource "aws_iam_user" "user_deploy" {

  name                 = var.default_admin_email
  path                 = "/"
  force_destroy        = true
  permissions_boundary = ""

  tags = merge(local.tags { EmailAddress : var.default_admin_email })
}

resource "aws_iam_user_group_membership" "user_deploy" {
  user   = var.default_admin_email
  groups = [
    aws_iam_group.administrators.name
  ]

  depends_on = [
    aws_iam_user.user_deploy
  ]
}

resource "aws_iam_user_policy_attachment" "user_deploy" {
  user       = var.default_admin_email
  policy_arn = [
    aws_iam_policy.ec2_describe.arn
  ]

  depends_on = [
    aws_iam_user.user_deploy,
  ]
}

output "user_deploy" {
  value = {
    arn       = aws_iam_user.user_deploy.arn
    unique_id = aws_iam_user.user_deploy.unique_id
  }
}

output "user_deploy_id" {
  value = aws_iam_access_key.user_deploy.id
}

output "user_deploy_secret" {
  value = aws_iam_access_key.user_deploy.secret
}