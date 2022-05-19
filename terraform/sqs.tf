resource "aws_sqs_queue" "sqs_from_s3_dlq" {
  name = "${var.prefix}-s3-queue-dlq"
  message_retention_seconds = 1209600
  receive_wait_time_seconds = 20
}

resource "aws_sqs_queue" "sqs_from_s3" {
  name                       = "${var.prefix}-s3-queue"
  visibility_timeout_seconds = 3600
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_from_s3_dlq.arn
    maxReceiveCount     = 3
  })

  policy = <<POLICY
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": "*",
              "Action": "sqs:SendMessage",
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Principal": "*",
              "Action": "sqs:SendMessage"
            }
          ]
        }
        POLICY
}