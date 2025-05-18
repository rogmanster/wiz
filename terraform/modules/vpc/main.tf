module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.name

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  cidr            = "10.0.0.0/16"
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["${var.private_subnet_az1_cidr}", "${var.private_subnet_az2_cidr}", "${var.private_subnet_az3_cidr}"]
  public_subnets  = ["${var.public_subnet_az1_cidr}", "${var.public_subnet_az2_cidr}", "${var.public_subnet_az3_cidr}"]

  private_subnet_tags = {
    "kubernetes.io/cluster/coder" : "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" : 1
  }
}



