#############################################################
# S3
#############################################################
resource "aws_s3_bucket" "data_bucket" {
  acl     = "private"
  bucket  = var.s3_data_bucket_name
  force_destroy = false

  versioning {
    enabled = true
  }

}