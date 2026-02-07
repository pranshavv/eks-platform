output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
  description = "Private subnet IDs"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public route table ID"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

output "nat_gateway_ids" {
  value       = var.enable_nat_gateway ? aws_nat_gateway.main[*].id : []
  description = "NAT Gateway IDs"
}

output "nat_public_ips" {
  value       = var.enable_nat_gateway ? aws_eip.nat[*].public_ip : []
  description = "NAT Gateway public IPs"
}