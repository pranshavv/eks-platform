variable "cluster_name" {
  type        = string
  description = "EKS cluster name to attach this node group to"
}

variable "node_group_name" {
  type        = string
  description = "Name of the EKS node group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for worker nodes"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 instance types for worker nodes"
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to node group resources"
}
