terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.79.0"
    }
  }

  backend "s3" {
    bucket         = "rogman-wiz-tfstate"
    key            = "vpc/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "public_key" {}

data "aws_eks_cluster" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

module "vpc" {
  source                  = "./modules/vpc"
  name                    = "wiz"
  region                  = "us-west-2"
  vpc_cidr                = "10.0.0.0/16"
  public_subnet_az1_cidr  = "10.0.10.0/24"
  public_subnet_az2_cidr  = "10.0.11.0/24"
  public_subnet_az3_cidr  = "10.0.12.0/24"
  private_subnet_az1_cidr = "10.0.20.0/24"
  private_subnet_az2_cidr = "10.0.21.0/24"
  private_subnet_az3_cidr = "10.0.22.0/24"
}

module "mongo" {
  source     = "./modules/db"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnet_ids[0]
  public_key = var.public_key
}

module "eks" {
  source             = "./modules/eks"
  region             = "us-west-2"
  name               = "wiz"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  cluster_version    = "1.30"
  instance_type      = "t3.medium"
  enable_irsa        = true
}

module "s3" {
  source = "./modules/s3"
}

module "tasky" {
  source            = "./modules/tasky"
  bucket_name       = module.s3.bucket_name
  mongodb_backup_sa = module.eks.mongodb_backup_service_account_name
  mongodb_ip        = module.mongo.mongodb_ip
  
  providers = {
    kubernetes = kubernetes
  }

}

output "update_kubeconfig" {
  value = module.eks.update_kubeconfig
}

output "mongodb_ip" {
  value = module.mongo.mongodb_ip
}

output "bucket_name" {
  value = module.s3.bucket_name
}

