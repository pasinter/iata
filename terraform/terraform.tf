terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "hkl-terraform"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
