variable "env" {
  default = "dev"
}

variable "aws_region" {
  description = "The AWS region"
  default     = "eu-central-1"
}

variable "prefix" {
  default     = "sales-records"
}

variable "fetch_data_lambda_zipfile" {
  default     = "../lambdas/fetch_data/lambda.zip"
}
