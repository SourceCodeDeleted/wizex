terraform {
  backend "s3" {
    bucket  = "wiz-tfstate-backend"
    key     = "wiz-exercise/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}