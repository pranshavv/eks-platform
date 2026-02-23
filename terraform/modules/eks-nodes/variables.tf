variable "cluster_name" {
  type        = string
  description = "EKS cluster name to attach node groups to"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for worker nodes"
}

# ── System Node Group Variables ─────────────────────────────────────────────

variable "system_instance_types" {
  type        = list(string)
  description = "Instance types for system node group (runs Karpenter, ArgoCD, Prometheus)"
  default     = ["t3.medium"]
}

variable "system_desired_size" {
  type        = number
  description = "Desired number of system nodes — keep same as min for stability"
  default     = 2
}

variable "system_min_size" {
  type        = number
  description = "Minimum system nodes — never goes below this"
  default     = 2
}

variable "system_max_size" {
  type        = number
  description = "Maximum system nodes — fixed, we don't scale system nodes"
  default     = 2
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all node group resources"
}