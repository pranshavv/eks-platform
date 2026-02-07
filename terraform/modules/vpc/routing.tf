# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name = "eks-platform-igw"
    }
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    var.common_tags,
    {
      Name = "eks-public-rt"
    }
  )
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# ==============================================================================
# NAT Gateway Resources (Optional - controlled by enable_nat_gateway variable)
# ==============================================================================

# Elastic IPs for NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = var.single_nat_gateway ? "eks-nat-eip" : "eks-nat-eip-${var.azs[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.single_nat_gateway ? aws_subnet.public_a.id : element([aws_subnet.public_a.id, aws_subnet.public_b.id], count.index)

  tags = merge(
    var.common_tags,
    {
      Name = var.single_nat_gateway ? "eks-nat-gateway" : "eks-nat-gateway-${var.azs[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.azs)) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    var.common_tags,
    {
      Name = var.single_nat_gateway ? "eks-private-rt" : "eks-private-rt-${var.azs[count.index]}"
    }
  )
}

# Private Subnet Route Table Association - AZ A
resource "aws_route_table_association" "private_a" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private[0].id
}

# Private Subnet Route Table Association - AZ B
resource "aws_route_table_association" "private_b" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = aws_subnet.private_b.id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[1].id
}