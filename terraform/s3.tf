resource "aws_s3_bucket" "landing-archive" {
  bucket = "${var.prefix}-landing-archive"
  acl           = "private"
  force_destroy = true
}
