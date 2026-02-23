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
