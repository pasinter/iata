resource "aws_s3_bucket" "landing_archive" {
  bucket = "${var.prefix}-landing-archive"
  acl           = "private"
  force_destroy = true
}


resource "aws_s3_bucket_notification" "landing_archive_new_file_notification" {
  bucket = aws_s3_bucket.landing_archive.id

  queue {
    queue_arn     = aws_sqs_queue.sqs_from_s3.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = "zip"
  }
}

resource "aws_s3_bucket" "sales_records_data" {
  bucket = "${var.prefix}-sales-records-data"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "glue_sales_records" {
  bucket = "${var.prefix}-glue_sales_records"
  acl           = "private"
  force_destroy = true
}
