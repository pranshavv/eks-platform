# VPC Configuration (MUST match your current VPC exactly)
vpc_cidr             = "10.0.0.0/16"
enable_dns_support   = true
enable_dns_hostnames = true

# Availability Zones
azs = [
  "ap-south-1a",
  "ap-south-1b"
]

# Public Subnets (MUST match current subnets exactly)
public_subnet_cidrs = [
  "10.0.0.0/24", # public_a
  "10.0.1.0/24"  # public_b
]

# Private Subnets (MUST match current subnets exactly)
private_subnet_cidrs = [
  "10.0.10.0/24", # private_a
  "10.0.11.0/24"  # private_b
]

# Tags
common_tags = {
  Name        = "eks-platform-vpc"
  Environment = "dev"
  ManagedBy   = "Terraform"
}

# NAT Gateway Configuration
# Set enable_nat_gateway = true when you need private subnet internet access
enable_nat_gateway = false
single_nat_gateway = true

# ==============================================================================
# EKS Configuration (disabled to save costs)
# Set enable_eks = true when you want to deploy
# Cost: ~$73/month for control plane when enabled
# ==============================================================================

cluster_name    = "eks-platform-dev"
cluster_version = "1.29"
enable_eks      = false


system_instance_types = ["t3.medium"]
system_desired_size   = 2
system_min_size       = 2
system_max_size       = 2
