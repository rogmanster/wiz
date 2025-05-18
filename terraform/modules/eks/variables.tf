variable "name" {}
variable "region" {}
variable "vpc_id" {}
variable "cluster_version" {}
variable "instance_type" {}
variable "enable_irsa" {}

variable "private_subnet_ids" {
  type = list(string)
}

variable "min_size" {
  default = 1
  type    = number
}

variable "max_size" {
  default = 2
  type    = number
}

variable "desired_size" {
  default = 1
  type    = number
}



