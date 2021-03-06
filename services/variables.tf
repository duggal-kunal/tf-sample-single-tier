variable "region" {}
variable "profile" {}

variable "owner" {}
variable "stage" {}
variable "service" {}
variable "component" {}
variable "prefix" {}
variable "creator" {}

variable "elb_name_all" {}
variable "sg_elb_name_all" {}


variable "ami_openapi" {}
variable "instance_type_openapi" {}
variable "elb_name_openapi" {}
variable "sg_elb_name_openapi" {}
variable "openapi_key" {}
variable "target_group_name_openapi" {
}

variable "ami_backend" {}
variable "instance_type_backend" {}
variable "backend_key" {}
variable "target_group_name_backend" {
}

variable "ami_gateway" {}
variable "instance_type_gateway" {}
variable "gateway_key" {}