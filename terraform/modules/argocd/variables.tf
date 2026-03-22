variable "depends_on_eks" {
  description = "Pass module.eks_nodes to ensure cluster is ready before ArgoCD installs"
  type        = any
  default     = null
}