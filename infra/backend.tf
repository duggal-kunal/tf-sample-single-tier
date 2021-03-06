terraform {
  backend "s3" {
    region = "us-west-2"
    bucket = "tf.single.tier.terraform.state"
    key = "us-west-2/infra/terraform.state"
	
    profile="vdsvcfpt"
  }
}