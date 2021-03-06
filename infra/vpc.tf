module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #version = "~> 1.66.0"
  version = "~> v1.0"
  name = "${var.prefix}-${var.region}-${var.stage}-${var.component}"
  cidr = "${var.vpc_stg_cidr}"

  azs             = ["${var.az1}", "${var.az2}"]
  private_subnets = ["${var.sub_pub_stg_cidr_1}", "${var.sub_pub_stg_cidr_2}"]
  public_subnets  = ["${var.sub_priv_stg_cidr_1}", "${var.sub_priv_stg_cidr_2}"]
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  #single_nat_gateway  = false
  #reuse_nat_ips       = true                 
  #external_nat_ip_ids = "${aws_eip.nat.*.id}"
  tags = {
    Owner = "${var.owner}"
    Stage = "${var.stage}"
    Service = "${var.service}"
    Creator = "${var.creator}"
    Component = "${var.component}"
  }

}