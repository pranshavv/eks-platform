# VPC Configuration - DIFFERENT CIDR from dev and stage
vpc_cidr             = "10.2.0.0/16"
enable_dns_support   = true
enable_dns_hostnames = true

# Availability Zones
azs = [
  "ap-south-1a",
  "ap-south-1b"
]

# Public Subnets
public_subnet_cidrs = [
  "10.2.0.0/24",
  "10.2.1.0/24"
]

# Private Subnets
private_subnet_cidrs = [
  "10.2.10.0/24",
  "10.2.11.0/24"
]

# Tags
common_tags = {
  Name        = "eks-platform-vpc"
  Environment = "prod"
  ManagedBy   = "Terraform"
}

# NAT Gateway Configuration
# Set enable_nat_gateway = true when you need private subnet internet access
enable_nat_gateway = false
single_nat_gateway = true