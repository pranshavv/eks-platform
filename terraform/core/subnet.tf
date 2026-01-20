# Public Subnet - ap-south-1a
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-ap-south-1a"
    

   "kubernetes.io/cluster/eks-platform" = "shared"
   "kubernetes.io/role/elb"             = "1"
  }
}

# Public Subnet - ap-south-1b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-ap-south-1b"


   "kubernetes.io/cluster/eks-platform" = "shared"
   "kubernetes.io/role/elb"             = "1"
  }
}

# Private Subnet - ap-south-1a
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "eks-private-ap-south-1a"

   "kubernetes.io/cluster/eks-platform" = "shared"
   "kubernetes.io/role/internal-elb"    = "1"
  }
}

# Private Subnet - ap-south-1b
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "eks-private-ap-south-1b"
 
    "kubernetes.io/cluster/eks-platform" = "shared"
    "kubernetes.io/role/internal-elb"    = "1"

   }
}

