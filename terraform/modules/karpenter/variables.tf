variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster API endpoint — Karpenter needs this to talk to cluster"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN — used to create IRSA trust relationship"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL — used to scope trust to Karpenter service account only"
}

variable "node_role_arn" {
  type        = string
  description = "IAM role ARN for nodes launched by Karpenter"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags"
}