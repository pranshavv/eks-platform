# Public Subnet - ap-south-1a
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                                     = "eks-public-${var.azs[0]}"
      "kubernetes.io/cluster/eks-platform"     = "shared"
      "kubernetes.io/role/elb"                 = "1"
    }
  )
}

# Public Subnet - ap-south-1b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                                     = "eks-public-${var.azs[1]}"
      "kubernetes.io/cluster/eks-platform"     = "shared"
      "kubernetes.io/role/elb"                 = "1"
    }
  )
}

# Private Subnet - ap-south-1a
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.azs[0]

  tags = merge(
    var.common_tags,
    {
      Name                                     = "eks-private-${var.azs[0]}"
      "kubernetes.io/cluster/eks-platform"     = "shared"
      "kubernetes.io/role/internal-elb"        = "1"
    }
  )
}

# Private Subnet - ap-south-1b
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.azs[1]

  tags = merge(
    var.common_tags,
    {
      Name                                     = "eks-private-${var.azs[1]}"
      "kubernetes.io/cluster/eks-platform"     = "shared"
      "kubernetes.io/role/internal-elb"        = "1"
    }
  )
}