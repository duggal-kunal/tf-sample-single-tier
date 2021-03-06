module "alb_openapi" {
  #count=2
  source                        = "terraform-aws-modules/alb/aws"
  version = "~> 3.0"
  load_balancer_name            = "${var.elb_name_openapi}"
  security_groups               = ["${module.elb_sg_openapi.this_security_group_id}"]
  logging_enabled               = "false"
  #log_bucket_name               = "logs-us-east-2-123456789012"
  #log_location_prefix           = "my-alb-logs"
  subnets                       = "${data.terraform_remote_state.infra.public_subnets}"
  tags                          = "${map("Owner", "${var.owner}","Stage","${var.stage}","Service","${var.service}","Creator","${var.creator}","Component","${var.component}")}"
  vpc_id                        = "${data.terraform_remote_state.infra.vpc_id}"
  http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  http_tcp_listeners_count      = "1"
  target_groups                 = "${list(map("name","${var.target_group_name_openapi}", "backend_protocol", "HTTP", "backend_port", "80","health_check_interval", "15","health_check_path","/test.html"))}"
  #health_check.0.interval       ="15"
  target_groups_count           = "1"
}

module "elb_sg_openapi" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 1.66.0"
  #version  = "1.21.0"
  version = "2.0"
  name        = "${var.prefix}-elbsg-${var.region}-${var.stage}-${var.component}-openapi"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "mypublicipaddress"
      cidr_blocks = "106.81.106.248/30"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "mypublicipaddress"
      cidr_blocks = "106.81.106.248/30"
    }
  ]

  egress_rules = ["all-all"]
  tags = {
    Owner = "${var.owner}"
    Stage = "${var.stage}"
    Service = "${var.service}"
    Creator = "${var.creator}"
    Component = "${var.component}"
  }


}

resource "aws_lb_target_group_attachment" "test1_openapi" {
  count=1
  target_group_arn="${module.alb_openapi.target_group_arns[0]}"
  target_id        = "${module.ec2_cluster_openapi.id[count.index]}"
}

module "ec2_cluster_openapi" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "1.21.0"

  instance_count         = 1
  name                   = "${var.prefix}-${var.region}-${var.stage}-${var.component}-openapi"

  ami                    = "${var.ami_openapi}"
  instance_type          = "${var.instance_type_openapi}"
  key_name               ="${var.openapi_key}"
  monitoring             = false
  vpc_security_group_ids = ["${module.sg_openapi.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.infra.private_subnets}"
  associate_public_ip_address = false
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
      source_security_group_id = "${module.elb_sg_openapi.this_security_group_id}"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = "${module.elb_sg_openapi.this_security_group_id}"
    },
    {
      rule                     = "rdp-tcp"
      source_security_group_id = "${module.sg_gateway.this_security_group_id}"
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