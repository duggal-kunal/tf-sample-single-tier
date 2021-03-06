module "ec2_cluster_gateway_1" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "1.21.0"

  instance_count         = 1
  name                   = "${var.prefix}-${var.region}-${var.stage}-${var.component}-gateway"

  ami                    = "${var.ami_gateway}"
  instance_type          = "${var.instance_type_gateway}"
  key_name               ="${var.gateway_key}"
  monitoring             = false
  vpc_security_group_ids = ["${module.sg_gateway.this_security_group_id}"]
  subnet_ids             = "${data.terraform_remote_state.infra.public_subnets}"
  associate_public_ip_address = true
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

module "sg_gateway" {
  source = "terraform-aws-modules/security-group/aws"
  #version = "~> 1.66.0"
  #version  = "1.21.0"
  version = "2.0"
  name        = "${var.prefix}-sg-${var.region}-${var.stage}-${var.component}-gateway"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"
  tags = {
    Owner = "${var.owner}"
    Stage = "${var.stage}"
    Service = "${var.service}"
    Creator = "${var.creator}"
    Component = "${var.component}"
  }
  ingress_with_cidr_blocks = [
    {
      from_port   = 3389
      to_port     = 3389
      protocol    = "tcp"
      description = "mypublicipaddress"
      cidr_blocks = "52.11.235.124/32"
    }
  ]
  egress_rules = ["all-all"]
  

}

resource "aws_eip_association" "terraform_gateway_ec2_eip_association" {
  count = "1"
  instance_id   = "${module.ec2_cluster_gateway_1.id[count.index]}"
  allocation_id = "${aws_eip.terraform-prd-eip-gateway.*.id[count.index]}"
  #allocation_id = "aws_eip.terraform-prd-eip-gateway.id"
}

# EIP
resource "aws_eip" "terraform-prd-eip-gateway" {
    count = "1"
    vpc = true
    tags {
        Owner = "${var.owner}"
        Stage = "${var.stage}"
        Service = "${var.service}"
        Creator = "${var.creator}"
        Component = "${var.component}"
        
    }
}