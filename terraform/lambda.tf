resource "aws_iam_role_policy" "LambdaExecutionRolePolicy" {
  name = "${var.prefix}-${var.project}-LambdaExecution"
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


resource "aws_lambda_function" "CreateCognitoUser" {
  function_name = "${var.prefix}-CreateCognitoUser"

  handler = "lambda.lambda_handler"
  runtime = "python3.6"
  filename= "${var.create_user_zipfile}"
  source_code_hash = "${base64sha256(file(var.create_user_zipfile))}"

  role = "${aws_iam_role.LambdaExecutionRole.arn}"

  timeout = 20

  environment {
    variables {
      cognitoUserPoolId = "${var.cognito_user_pool_id}"
      cognitoClientId = "${var.cognito_client_id}"
      cognitoEnabledGroups = "${jsonencode(var.cognito_enabled_groups)}"
      saml_provider_name = "${var.saml_provider_name}"
      saml_email_attribute_name = "${var.saml_email_attribute_name}"
      saml_sso_id_attribute_name = "${var.saml_sso_id_attribute_name}"
    }
  }

  depends_on = [ "aws_iam_role.LambdaExecutionRole" ]

  tags = "${merge(
    var.default_tags,
    map()
  )}"
}