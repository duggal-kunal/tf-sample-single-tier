provider "aws" {
  #version = "~> 2.13"
  region = "${var.region}"
  profile= "${var.profile}"
}

