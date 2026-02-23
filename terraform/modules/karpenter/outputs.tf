output "karpenter_controller_role_arn" {
  value       = aws_iam_role.karpenter_controller.arn
  description = "IAM role ARN for Karpenter controller — used when installing Karpenter via Helm"
}