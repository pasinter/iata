resource "aws_s3_bucket" "landing_archive" {
  bucket = "${var.prefix}-landing-archive"
  acl           = "private"
  force_destroy = true
}


resource "aws_s3_bucket_notification" "landing_archive_new_file_notification" {
  bucket = aws_s3_bucket.landing_archive.id

  queue {
    queue_arn     = aws_sqs_queue.data_fetched.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = "zip"
  }
}

resource "aws_s3_bucket" "sales_records_csv" {
  bucket = "${var.prefix}-csv-data"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_notification" "data_extracted_notification" {
  bucket = aws_s3_bucket.sales_records_csv.id

  queue {
    queue_arn     = aws_sqs_queue.data-extracted.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = ""
    filter_suffix = "zip"
  }
}

resource "aws_s3_bucket" "sales_records_parquet" {
  bucket = "${var.prefix}-parquet-data"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket" "glue_sales_records" {
  bucket = "${var.prefix}-glue-sales-records"
  acl           = "private"
  force_destroy = true
}
