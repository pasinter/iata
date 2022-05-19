terraform {
  required_version = ">= 0.12"
  backend "s3" {
    profile = "default"
    bucket = "iata-terraform"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
