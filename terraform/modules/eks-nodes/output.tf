output "system_node_group_name" {
  value       = aws_eks_node_group.system.node_group_name
  description = "Name of the system node group"
}

output "system_node_group_arn" {
  value       = aws_eks_node_group.system.arn
  description = "ARN of the system node group"
}

output "node_role_arn" {
  value       = aws_iam_role.node.arn
  description = "IAM role ARN used by worker nodes — also used by Karpenter in Step 3"
}