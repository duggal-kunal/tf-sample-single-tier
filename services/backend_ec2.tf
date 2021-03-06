module "ec2_cluster_backend" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "1.21.0"

  instance_count         = 1
  name                   = "${var.prefix}-${var.region}-${var.stage}-${var.component}-backend"

  ami                    = "${var.ami_backend}"
  instance_type          = "${var.instance_type_backend}"
  key_name               ="${var.backend_key}"
  monitoring             = false
  vpc_security_group_ids = ["${module.sg_backend.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.infra.private_subnets}"
  associate_public_ip_address = true
  disable_api_termination = true
  #iam_instance_profile = "tf-realy-openapi"
  #root_block_device  = ["aws_ebs_volume.root.id"]
  #root_block_device  = ["${aws_ebs_volume.root.id}","${aws_ebs_volume.root.id}"]
  #root_volume_size = "20"
  tags = {
    Owner = "${var.owner}"
    Stage = "${var.stage}"
    Service = "${var.service}"
    Creator = "${var.creator}"
    Component = "${var.component}"
  }

}

module "sg_backend" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 1.66.0"
  #version  = "1.21.0"
  version = "2.0"
  name        = "${var.prefix}-sg-${var.region}-${var.stage}-${var.component}-backend"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.elb_sg_all_1.this_security_group_id}"
    },
    {
      rule                     = "rdp-tcp"
      source_security_group_id = "${module.sg_gateway.this_security_group_id}"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = "${module.elb_sg_all_1.this_security_group_id}"
    }

  ]
  number_of_computed_ingress_with_source_security_group_id = 3
  egress_rules = ["all-all"]
  tags = {
    Owner = "${var.owner}"
    Stage = "${var.stage}"
    Service = "${var.service}"
    Creator = "${var.creator}"
    Component = "${var.component}"
  }
}

