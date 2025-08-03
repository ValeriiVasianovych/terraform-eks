terraform {
  backend "s3" {
    bucket       = "terraform-states-vv"
    key          = "eks-stage-2/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = local.vpc_region

  default_tags {
    tags = {
      Owner       = "Valerii Vasianovych with ID"
      Project     = "Cybersecurity Project in ${local.vpc_region} region. Project: AWS Cloud and Terraform IaC"
      Environment = local.vpc_env
      Region      = "Region: ${local.vpc_region}"
      ManagedBy   = "Terraform"
      Stage       = "Stage 2 - Cluster Configuration"
    }
  }
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "access-management" {
  source       = "../../../modules/access-management"
  region       = local.vpc_region
  env          = local.vpc_env
  account_id   = data.aws_caller_identity.current.id
  cluster_name = local.cluster_name
  depends_on   = [data.aws_eks_cluster.eks]
}

module "hpa" {
  source     = "../../../modules/hpa"
  env        = local.vpc_env
  depends_on = [data.aws_eks_cluster.eks]
}

module "cluster-autoscaler" {
  source               = "../../../modules/cluster-autoscaler"
  cluster_name         = local.cluster_name
  region               = local.vpc_region
  env                  = local.vpc_env
  pod_identity_version = local.pod_identity_version
  depends_on           = [module.hpa]
}

module "helm-charts" {
  source       = "../../../modules/helm-charts"
  env          = local.vpc_env
  cluster_name = local.cluster_name
  depends_on   = [module.cluster-autoscaler]
}

module "loadbalancer-controller" {
  source       = "../../../modules/loadbalancer-controller"
  env          = local.vpc_env
  cluster_name = local.cluster_name
  vpc_id       = local.vpc_id
  depends_on   = [module.helm-charts]
}

module "ebs-csi" {
  source          = "../../../modules/ebs-csi"
  env             = local.vpc_env
  cluster_name    = local.cluster_name
  depends_on      = [module.loadbalancer-controller]
  ebs_csi_version = local.ebs_csi_version
}
