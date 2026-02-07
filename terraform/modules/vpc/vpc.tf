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