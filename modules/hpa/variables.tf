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

variable "account_id" {
  description = "The AWS account ID"
  type        = string
  default     = ""
}

variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    default     = ""
}