terraform {
  backend "s3" {
    bucket       = "terraform-states-vv"
    key          = "eks/terraform.tfstate"
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
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "vpc" {
  source = "../../modules/vpc"

  region     = var.region
  env        = var.env
  account_id = data.aws_caller_identity.current.account_id

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24"]
}

module "eks" {
  source             = "../../modules/eks"
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

  coredns_version      = local.coredns_version
  kube_proxy_version   = local.kube_proxy_version
  vpc_cni_version      = local.vpc_cni_version
  # ebs_csi_version    = local.ebs_csi_version

  depends_on = [module.vpc]
}

module "access-management" {
  source       = "../../modules/access-management"
  region       = var.region
  env          = var.env
  account_id   = data.aws_caller_identity.current.id
  cluster_name = module.eks.cluster_name
  depends_on   = [module.vpc, module.eks]
}

module "hpa" {
  source     = "../../modules/hpa"
  env        = var.env
  depends_on = [module.vpc, module.eks]
}

module "cluster-autoscaler" {
  source               = "../../modules/cluster-autoscaler"
  cluster_name         = module.eks.cluster_name
  region               = var.region
  env                  = var.env
  pod_identity_version = local.pod_identity_version
  depends_on           = [module.hpa]
}
