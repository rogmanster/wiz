provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_name                    = "${var.name}-eks-cluster"
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }
  
  eks_managed_node_groups = {
    default = {
      min_size     = var.min_size 
      max_size     = var.max_size
      desired_size = var.desired_size

      instance_types = [ var.instance_type ]
      capacity_type  = "ON_DEMAND"

      # Needed by the aws-ebs-csi-driver
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    
      launch_template_tags = { 
        Environment = "prod",
        Name        = "${var.name}-eks-instance"
      }
    }
  }
  tags = {
    Environment = "prod"
    Name        = "${var.name}-eks-cluster"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name ]
  }
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = true
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  allow_volume_expansion = true
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
    encrypted = false
    fsType = "ext4"
  }
}

