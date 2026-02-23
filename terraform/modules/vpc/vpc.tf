# modules/vpc/vpc.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr              # From variable
  enable_dns_support   = var.enable_dns_support    # From variable
  enable_dns_hostnames = var.enable_dns_hostnames  # From variable
  
  tags = merge(
    var.common_tags,
    {
      Name = "eks-platform-vpc"
    }
  )
}
resource "aws_security_group" "karpenter_nodes" {
  name        = "${var.cluster_name}-karpenter-nodes"
  description = "Security group for nodes launched by Karpenter"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.common_tags,
    {
      Name                         = "${var.cluster_name}-karpenter-nodes"
      "karpenter.sh/discovery"     = var.cluster_name
    }
  )
}