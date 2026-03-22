# ── Karpenter Controller IAM Role (IRSA) ───────────────────────────────────
# This is the role Karpenter pod itself assumes
# Scoped strictly to karpenter service account in karpenter namespace

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
# Permissions Karpenter needs to launch and terminate EC2 instances

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
        Action = [
          "eks:DescribeCluster"
        ]
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

# # ── Karpenter Helm Install ──────────────────────────────────────────────────
# # Actually installs Karpenter onto the cluster via Helm
# # IAM + IRSA above must exist before this runs

# resource "helm_release" "karpenter" {
#   name       = "karpenter"
#   namespace  = "karpenter"
#   repository = "oci://public.ecr.aws/karpenter"
#   chart      = "karpenter"
#   version    = "v0.37.0"

#   create_namespace = true

#   set {
#     name  = "settings.clusterName"
#     value = var.cluster_name
#   }

#   set {
#     name  = "settings.clusterEndpoint"
#     value = var.cluster_endpoint
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.karpenter_controller.arn
#   }

#   set {
#     name  = "controller.resources.requests.cpu"
#     value = "250m"
#   }

#   set {
#     name  = "controller.resources.requests.memory"
#     value = "256Mi"
#   }

#   set {
#     name  = "controller.resources.limits.cpu"
#     value = "500m"
#   }

#   set {
#     name  = "controller.resources.limits.memory"
#     value = "512Mi"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.karpenter_controller
#   ]
# }