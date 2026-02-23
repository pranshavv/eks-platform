# ── IAM Role (shared by both node groups) ──────────────────────────────────

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ── System Node Group ───────────────────────────────────────────────────────
# Runs: Karpenter, CoreDNS, kube-proxy, ArgoCD, Prometheus
# Fixed size — never scales down
# Tainted so app pods never land here

resource "aws_eks_node_group" "system" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-system-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.system_instance_types

  scaling_config {
    desired_size = var.system_desired_size
    min_size     = var.system_min_size
    max_size     = var.system_max_size
  }

  taint {
    key    = "dedicated"
    value  = "system"
    effect = "NO_SCHEDULE"
  }

  labels = {
    role = "system"
  }

  capacity_type = "ON_DEMAND"
  tags          = var.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr
  ]
}