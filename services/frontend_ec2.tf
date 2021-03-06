module "ec2_cluster_openapi_1" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "1.21.0"

  instance_count         = 2
  name                   = "${var.prefix}-${var.region}-${var.stage}-${var.component}-openapi" 

  ami                    = "${var.ami_openapi}"
  instance_type          = "${var.instance_type_openapi}"
  key_name               ="${var.openapi_key}"
  monitoring             = false
  vpc_security_group_ids = ["${module.sg_openapi.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.infra.public_subnets}"
  associate_public_ip_address = false
  disable_api_termination = true
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

module "sg_openapi" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 1.66.0"
  #version  = "1.21.0"
  version = "2.0"
  name        = "${var.prefix}-sg-${var.region}-${var.stage}-${var.component}-openapi"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.sg_openapi.this_security_group_id}"
    },
    {
      rule                     = "ssh-tcp"
      source_security_group_id = "${module.sg_gateway.this_security_group_id}"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = "${module.sg_openapi.this_security_group_id}"
    },
    {
      from_port                = 8092
      to_port                  = 8092
      protocol                 = 6
      description              = "Service Name"
      source_security_group_id = "${module.sg_openapi.this_security_group_id}"
    }

  ]
  number_of_computed_ingress_with_source_security_group_id = 4
  egress_rules = ["all-all"]
  
  tags = {
    Owner = "${var.owner}"
    Stage = "${var.stage}"
    Service = "${var.service}"
    Creator = "${var.creator}"
    Component = "${var.component}"
  }

}