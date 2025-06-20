variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment"
  type        = string
  default     = "development"
}

locals {
  cluster_version = "1.32"
  desired_size    = 2
  max_size        = 4
  min_size        = 2
  max_unavailable = 1
  capacity_type   = "ON_DEMAND"
  instance_types  = "t3.small"
  ingress_ports   = [80, 443]

  coredns_version      = "v1.11.4-eksbuild.14"
  kube_proxy_version   = "v1.32.3-eksbuild.7"
  vpc_cni_version      = "v1.19.5-eksbuild.3"
  pod_identity_version = "v1.3.7-eksbuild.2"

  # ebs_csi_version    = "v1.44.0-eksbuild.1"
}
