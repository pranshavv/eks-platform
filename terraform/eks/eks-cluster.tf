resource "aws_eks_cluster" "this" {
  name     = "eks-platform"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      data.terraform_remote_state.core.outputs.public_subnet_a_id,
      data.terraform_remote_state.core.outputs.public_subnet_b_id,
      data.terraform_remote_state.core.outputs.private_subnet_a_id,
      data.terraform_remote_state.core.outputs.private_subnet_b_id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

