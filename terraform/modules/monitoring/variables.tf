variable "depends_on_eks" {
  description = "Pass module.eks_nodes to ensure cluster is ready"
  type        = any
  default     = null
}