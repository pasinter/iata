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