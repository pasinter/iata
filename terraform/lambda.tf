resource "aws_iam_role" "LambdaExecutionRole" {
  name = "${var.prefix}-LambdaExecution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BasicStsAccessForLambda",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

data "aws_iam_policy" "s3_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "eks_service_account_s3_full_access" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = data.aws_iam_policy.s3_full_access.arn
}

resource "aws_iam_role_policy" "LambdaExecutionRolePolicy" {
  name = "${var.prefix}-LambdaExecution"
  role = "${aws_iam_role.LambdaExecutionRole.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BasicLogAccessForLambda",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ConfigureLambdaVPC",
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupEgress",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateNetworkInterface",
        "ec2:CreateSecurityGroup",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcAttribute",
        "ec2:DescribeVpcs",
        "ec2:DeleteNetworkInterface",
        "ec2:DeleteSecurityGroup",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:DescribeNetworkInterfaces"
       ],
      "Resource": "*"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "sqs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_lambda_function" "fetch-data" {
  function_name = "${var.prefix}-fetch-data"

  handler = "lambda_handler.lambda_handler"
  runtime = "python3.6"
  filename= var.fetch_data_lambda_zipfile
  source_code_hash = filebase64sha256(var.fetch_data_lambda_zipfile)

  role = "${aws_iam_role.LambdaExecutionRole.arn}"

  timeout = 500

  environment {
    variables = {
      ARCHIVE_BUCKET_NAME=aws_s3_bucket.landing_archive.bucket
    }
  }

  depends_on = [ aws_iam_role.LambdaExecutionRole ]
}

resource "aws_lambda_function" "extract-csv" {
  function_name = "${var.prefix}-extract-csv"

  handler = "lambda_handler.lambda_handler"
  runtime = "python3.6"
  filename= var.extract_csv_lambda_zipfile
  source_code_hash = filebase64sha256(var.extract_csv_lambda_zipfile)

  role = "${aws_iam_role.LambdaExecutionRole.arn}"

  timeout = 500
  memory_size = 512

  environment {
    variables = {
      CSV_BUCKET_NAME=aws_s3_bucket.sales_records_csv.bucket
    }
  }

  depends_on = [ aws_iam_role.LambdaExecutionRole ]
}

resource "aws_lambda_function_event_invoke_config" "sqs_s3_events_lambda_function_event_invoke_config_extract_csv" {
  function_name          = aws_lambda_function.extract-csv.function_name
  maximum_retry_attempts = 0
}

resource "aws_lambda_event_source_mapping" "sqs_s3_events_lambda_event_source_mapping_extract_csv" {
  event_source_arn = aws_sqs_queue.data_fetched.arn
  function_name    = aws_lambda_function.extract-csv.arn
  batch_size       = 1

  depends_on = [ aws_lambda_function.extract-csv, aws_sqs_queue.data_fetched ]
}

resource "aws_lambda_function" "convert-to-parquet" {
  function_name = "${var.prefix}-convert-to-parquet"

  handler = "lambda_handler.lambda_handler"
  runtime = "python3.6"
  filename= var.convert_to_parquet_lambda_zipfile
  source_code_hash = filebase64sha256(var.convert_to_parquet_lambda_zipfile)

  role = "${aws_iam_role.LambdaExecutionRole.arn}"

  timeout = 500
  memory_size = 512

  environment {
    variables = {
      PARQUET_DATA_BUCKET_NAME=aws_s3_bucket.sales_records_parquet.bucket
    }
  }

  depends_on = [ aws_iam_role.LambdaExecutionRole ]
}

resource "aws_lambda_function_event_invoke_config" "sqs_s3_events_lambda_function_event_invoke_config_convert-to-parquet" {
  function_name          = aws_lambda_function.convert-to-parquet.function_name
  maximum_retry_attempts = 0

  depends_on = [ aws_lambda_function.convert-to-parquet ]
}

resource "aws_lambda_event_source_mapping" "sqs_s3_events_lambda_event_source_mapping_convert-to-parquet" {
  event_source_arn = aws_sqs_queue.data-extracted.arn
  function_name    = aws_lambda_function.convert-to-parquet.arn
  batch_size       = 1

  depends_on = [ aws_lambda_function.convert-to-parquet, aws_sqs_queue.data-extracted ]
}
