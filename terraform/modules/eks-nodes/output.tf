output "node_group_name" {
  value       = aws_eks_node_group.this.node_group_name
  description = "Name of the EKS node group"
}

output "node_group_arn" {
  value       = aws_eks_node_group.this.arn
  description = "ARN of the EKS node group"
}

output "node_role_arn" {
  value       = aws_iam_role.node.arn
  description = "IAM role ARN used by worker nodes"
}
