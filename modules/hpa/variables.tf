variable "env" {
  description = "The environment"
  type        = string
  default     = ""
}

variable "cluster_auth" {
    description = "The authentication method for the EKS cluster"
    type        = string
    default     = ""
}

variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
    default     = ""
}