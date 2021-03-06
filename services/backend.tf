terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "tf.single.tier.terraform.state"
    key = "us-west-2/services/terraform.state"

    profile="vdsvcfpt"
  }
}

data "terraform_remote_state" "infra" {
  backend ="s3"
  config {
    region = "us-west-2"
    bucket = "tf.single.tier.terraform.state"
    key = "us-west-2/services/terraform.state"
    profile="vdsvcfpt"
    encrypt = true
    lock_table = "TerraformLock"
    acl = "bucket-owner-full-control"
  }
}


