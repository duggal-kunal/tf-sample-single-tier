module "alb_all_1" {
  #count=2
  source                        = "terraform-aws-modules/alb/aws"
  version = "~> 3.0"
  load_balancer_name            = "${var.elb_name_all}"
  security_groups               = ["${module.elb_sg_all_1.this_security_group_id}"]
  logging_enabled               = "false"
  #log_bucket_name               = "logs-us-east-2-123456789012"
  #log_location_prefix           = "my-alb-logs"
  subnets                       = "${data.terraform_remote_state.infra.private_subnets}"
  tags                          = "${map("Owner", "${var.owner}","Stage","${var.stage}","Service","${var.service}","Creator","${var.creator}","Component","${var.component}")}"
  vpc_id                        = "${data.terraform_remote_state.infra.vpc_id}"
  #http_tcp_listeners            = "${list(map("port", "80", "protocol", "HTTP"))}"
  #http_tcp_listeners_count      = "1"
  http_tcp_listeners = [
    {
      "port"               = 80
      "protocol"           = "HTTP"
      "target_group_index" = 0
    },
    {
      "port"               = 8983
      "protocol"           = "HTTP"
      "target_group_index" = 1
    },

  ]
  http_tcp_listeners_count      = "2"  
  load_balancer_is_internal     = true  
  target_groups = [
    {
      "name"             = "${var.target_group_name_backend}"
      "backend_protocol" = "HTTP"
      "backend_port"     = 80
	  "health_check_path" = "/test.html"
    },

  ]
  
  target_groups_count           = "2"
  target_groups_defaults        = "${map("healthy_threshold", "10")}"
  /*
  target_groups_defaults = [
    {
      "healthy_threshold"     = 10
    },
    {
      "healthy_threshold"     = 15
    },
    {
      "healthy_threshold"     = 20
    },
    {
      "healthy_threshold"     = 25
    },
    {
      "healthy_threshold"     = 30
    },
  ]
  */
}

module "asg_mysample" {
  source = "terraform-aws-modules/autoscaling/aws"

  lc_name = "myexample-lc"

  image_id        = "${var.ami_backend}"
  instance_type   = "${var.instance_type_backend}"
  security_groups = ["${module.sg_backend.this_security_group_id}"]

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "myexample-asg"
  vpc_zone_identifier       = ["${data.terraform_remote_state.infra.private_subnets}"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "stg"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "mySample"
      propagate_at_launch = true
    },
  ]
}

module "elb_sg_all_1" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 1.66.0"
  #version  = "1.21.0"
  version = "2.0"
  name        = "${var.prefix}-elbsg-${var.region}-${var.stage}-${var.component}-all"
  description = "Security group for user-service with custom ports open within VPC"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"
  
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.sg_openapi.this_security_group_id}"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = "${module.sg_openapi.this_security_group_id}"
    },
    {
      rule                     = "http-80-tcp"
      source_security_group_id = "${module.sg_feedapi.this_security_group_id}"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = "${module.sg_feedapi.this_security_group_id}"
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

resource "aws_lb_target_group_attachment" "test1_backend" {
  count=1
  target_group_arn="${module.alb_all_1.target_group_arns[0]}"
  target_id        = "${module.ec2_cluster_relay.id[count.index]}"
}

/*
resource "aws_nat_gateway" "nat-virginia-gw" {
  count = "1"
  allocation_id = "eipalloc-0ae4753a49e09914c"
  subnet_id ="${data.terraform_remote_state.infra.public_subnets[0]}"
  depends_on = ["aws_internet_gateway.igw-terraform-virginia-terra"]
  tags
{
    Name  = "${var.creator}-${element(var.az_code, count.index)}-${var.service_id}-${var.tag_stage}-ngw"
    Service="${var.service_id}"
    Owner="${var.tag_owner}"
}
}

*/