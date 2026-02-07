output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "nat_gateway_ids" {
  value       = module.vpc.nat_gateway_ids
  description = "NAT Gateway IDs"
}

output "nat_public_ips" {
  value       = module.vpc.nat_public_ips
  description = "NAT Gateway public IPs"
}

# ==============================================================================
# EKS Outputs (only if enabled)
# ==============================================================================

output "cluster_endpoint" {
  value       = var.enable_eks && length(module.eks_cluster) > 0 ? module.eks_cluster[0].cluster_endpoint : null
  description = "EKS cluster API endpoint"
}

output "cluster_name" {
  value       = var.enable_eks && length(module.eks_cluster) > 0 ? module.eks_cluster[0].cluster_id : null
  description = "EKS cluster name"
}