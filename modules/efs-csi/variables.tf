variable "env" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "efs_csi_version" {
  description = "Version of EFS CSI driver addon to install"
  type        = string
  default     = "v1.7.4-eksbuild.1"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "The security group ID for the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

