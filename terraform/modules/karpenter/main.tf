# ── Karpenter Controller IAM Role (IRSA) ───────────────────────────────────
data "aws_iam_policy_document" "karpenter_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.cluster_name}-karpenter-controller"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
  tags               = var.common_tags
}

# ── Karpenter Controller Policy ─────────────────────────────────────────────
resource "aws_iam_policy" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KarpenterEC2"
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:RunInstances",
          "ec2:CreateTags",
          "ec2:TerminateInstances",
          "ec2:DeleteLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotPriceHistory"
        ]
        Resource = "*"
      },
      {
        Sid      = "KarpenterIAMPassRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = var.node_role_arn
      },
      {
        Sid    = "KarpenterEKS"
        Effect = "Allow"
        Action = ["eks:DescribeCluster"]
        Resource = "*"
      },
      {
        Sid    = "KarpenterPricing"
        Effect = "Allow"
        Action = [
          "pricing:GetProducts",
          "ssm:GetParameter"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller.arn
}

# ── Karpenter Helm Install ──────────────────────────────────────────────────
# Actually installs Karpenter onto the cluster via Helm
# IAM + IRSA above must exist before this runs

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.37.0"

  create_namespace = true

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
  name  = "clusterName"
  value = var.cluster_name
  }

  set {
  name  = "clusterEndpoint"
  value = var.cluster_endpoint
  }

  values = [
    <<-EOT
    controller:
      resources:
        requests:
          cpu: "250m"
          memory: "256Mi"
        limits:
          cpu: "500m"
          memory: "512Mi"
    EOT
  ]

  depends_on = [
    aws_iam_role_policy_attachment.karpenter_controller
  ]
}

# ── Karpenter Node Manifests ────────────────────────────────────────────────
# EC2NodeClass — defines what kind of nodes Karpenter launches
# NodePool — defines when and how many nodes to launch

resource "kubectl_manifest" "ec2nodeclass" {
  yaml_body = file("${path.module}/manifests/ec2nodeclass.yaml")

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "nodepool" {
  yaml_body = file("${path.module}/manifests/nodepool.yaml")

  depends_on = [
    helm_release.karpenter,
    kubectl_manifest.ec2nodeclass
  ]
}