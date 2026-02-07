variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version to use for the EKS cluster"
  default     = "1.29"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the EKS cluster"
}

variable "endpoint_private_access" {
  type        = bool
  description = "Enable private API server endpoint"
  default     = true
}

variable "endpoint_public_access" {
  type        = bool
  description = "Enable public API server endpoint"
  default     = true
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources"
  default     = {}
}