variable "region" {
  description = "The AWS region"
  type        = string
  default     = ""
}

variable "env" {
  description = "The environment"
  type        = string
  default     = ""
}

variable "pod_identity_version" {
  description = "Version of Pod Identity addon"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = ""
}

variable "ebs_csi_version" {
  description = "Version of EBS CSI addon"
  type        = string
  default     = ""
}

