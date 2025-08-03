terraform {
  backend "s3" {
    bucket       = "terraform-states-vv"
    key          = "eks-stage-1/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = "Valerii Vasianovych with ID"
      Project     = "Cybersecurity Project in ${var.region} region. Project: AWS Cloud and Terraform IaC"
      Environment = var.env
      Region      = "Region: ${var.region}"
      ManagedBy   = "Terraform"
      Stage       = "Stage 1 - Infra Creation"
    }
  }
}

module "vpc" {
  source = "../../../modules/vpc"

  region     = var.region
  env        = var.env
  account_id = data.aws_caller_identity.current.account_id

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24"]
}

module "eks" {
  source             = "../../../modules/eks"
  region             = var.region
  env                = var.env
  account_id         = data.aws_caller_identity.current.id
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_version = local.cluster_version
  desired_size    = local.desired_size
  max_size        = local.max_size
  min_size        = local.min_size
  max_unavailable = local.max_unavailable
  capacity_type   = local.capacity_type
  instance_types  = local.instance_types
  ingress_ports   = local.ingress_ports

  coredns_version    = local.coredns_version
  kube_proxy_version = local.kube_proxy_version
  vpc_cni_version    = local.vpc_cni_version
  # ebs_csi_version    = local.ebs_csi_version

  depends_on = [module.vpc]
}
