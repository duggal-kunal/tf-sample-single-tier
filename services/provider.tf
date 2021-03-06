provider "aws" {
  #version = "~> 2.13"
  region = "${var.region}"
  profile= "${var.profile}"
  shared_credentials_file = "C:/Users/kunal.duggal/.aws/credentials"
}

