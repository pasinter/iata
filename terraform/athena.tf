resource "aws_athena_workgroup" "this" {
  name = "${var.prefix}-athena-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_workgroup_results.bucket}/output/"
    }
  }
}

resource "aws_s3_bucket" "athena_workgroup_results" {
  bucket = "${var.prefix}-athena-workgroup-results"
  acl           = "private"
  force_destroy = true

}

resource "aws_s3_bucket_public_access_block" "block_public_access_on_athena_workgroup_results" {
  bucket = aws_s3_bucket.athena_workgroup_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}